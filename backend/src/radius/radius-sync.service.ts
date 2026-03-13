import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { PrismaService } from '../prisma/prisma.service';
import { RadiusService } from './radius.service';
import { MikroTikApiService } from '../mikrotik/mikrotik-api.service';
import { VoucherStatus, CountType } from '@prisma/client';
import * as crypto from 'crypto';

/**
 * RadiusSyncService handles periodic jobs:
 *
 * 1. Session Sync: Reads RADIUS accounting data (radacct) and syncs it
 *    into the app's Session table for dashboard/monitoring.
 *
 * 2. Voucher Activation: Detects first-use of UNUSED vouchers via radpostauth
 *    and starts their expiration timer.
 *
 * 3. Voucher Expiration: Marks expired vouchers as EXPIRED, removes their
 *    RADIUS credentials, and disconnects active sessions from MikroTik.
 */
@Injectable()
export class RadiusSyncService {
    private readonly logger = new Logger(RadiusSyncService.name);

    constructor(
        private prisma: PrismaService,
        private radiusService: RadiusService,
        private mikrotikApi: MikroTikApiService,
    ) { }

    /**
     * Decrypt router password (same logic as RoutersService)
     */
    private decryptPassword(encryptedPassword: string): string {
        try {
            const algorithm = 'aes-256-cbc';
            const key = crypto.scryptSync(process.env.JWT_SECRET!, 'salt', 32);

            const parts = encryptedPassword.split(':');
            if (parts.length !== 2) {
                throw new Error('Invalid encrypted password format');
            }

            const iv = Buffer.from(parts[0], 'hex');
            const encrypted = parts[1];

            const decipher = crypto.createDecipheriv(algorithm, key, iv);
            let decrypted = decipher.update(encrypted, 'hex', 'utf8');
            decrypted += decipher.final('utf8');

            return decrypted;
        } catch (error) {
            this.logger.error(`Password decryption failed: ${error.message}`);
            throw new Error('Failed to decrypt router credentials');
        }
    }

    // ==========================================
    // SESSION SYNC — every 5 minutes
    // ==========================================

    @Cron(CronExpression.EVERY_5_MINUTES)
    async syncSessions() {
        try {
            // Find active RADIUS sessions (no stop time)
            const activeSessions = await this.prisma.radAcct.findMany({
                where: { acctstoptime: null },
                select: {
                    acctuniqueid: true,
                    username: true,
                    nasipaddress: true,
                    framedipaddress: true,
                    callingstationid: true,
                    acctstarttime: true,
                    acctsessiontime: true,
                    acctinputoctets: true,
                    acctoutputoctets: true,
                },
            });

            let synced = 0;

            for (const acct of activeSessions) {
                if (!acct.nasipaddress || !acct.username) continue;

                // Find the router by NAS IP (could be ipAddress or vpnIp)
                const router = await this.prisma.router.findFirst({
                    where: {
                        OR: [
                            { ipAddress: acct.nasipaddress },
                            { vpnIp: acct.nasipaddress },
                        ],
                    },
                    select: { id: true },
                });

                if (!router) continue;

                // Find the voucher by username
                const voucher = await this.prisma.voucher.findFirst({
                    where: { username: acct.username, routerId: router.id },
                    select: { id: true },
                });

                // Upsert session — use acctuniqueid as the key
                const existingSession = await this.prisma.session.findFirst({
                    where: {
                        username: acct.username,
                        routerId: router.id,
                        isActive: true,
                    },
                });

                const sessionData = {
                    username: acct.username,
                    ipAddress: acct.framedipaddress || null,
                    macAddress: acct.callingstationid || null,
                    bytesIn: acct.acctinputoctets || BigInt(0),
                    bytesOut: acct.acctoutputoctets || BigInt(0),
                    uptime: acct.acctsessiontime || 0,
                    startTime: acct.acctstarttime || new Date(),
                    isActive: true,
                    routerId: router.id,
                    voucherId: voucher?.id || null,
                };

                if (existingSession) {
                    await this.prisma.session.update({
                        where: { id: existingSession.id },
                        data: {
                            bytesIn: sessionData.bytesIn,
                            bytesOut: sessionData.bytesOut,
                            uptime: sessionData.uptime,
                            ipAddress: sessionData.ipAddress,
                            macAddress: sessionData.macAddress,
                        },
                    });
                } else {
                    await this.prisma.session.create({ data: sessionData });
                }

                synced++;
            }

            // Also sync completed sessions (have stop time)
            const recentlyStopped = await this.prisma.radAcct.findMany({
                where: {
                    acctstoptime: {
                        not: null,
                        gte: new Date(Date.now() - 10 * 60 * 1000), // Last 10 minutes
                    },
                },
                select: {
                    username: true,
                    nasipaddress: true,
                    acctstoptime: true,
                    acctsessiontime: true,
                    acctinputoctets: true,
                    acctoutputoctets: true,
                },
            });

            for (const acct of recentlyStopped) {
                if (!acct.nasipaddress || !acct.username) continue;

                const router = await this.prisma.router.findFirst({
                    where: {
                        OR: [
                            { ipAddress: acct.nasipaddress },
                            { vpnIp: acct.nasipaddress },
                        ],
                    },
                    select: { id: true },
                });

                if (!router) continue;

                // Mark corresponding app session as inactive
                await this.prisma.session.updateMany({
                    where: {
                        username: acct.username,
                        routerId: router.id,
                        isActive: true,
                    },
                    data: {
                        isActive: false,
                        endTime: acct.acctstoptime,
                        bytesIn: acct.acctinputoctets || BigInt(0),
                        bytesOut: acct.acctoutputoctets || BigInt(0),
                        uptime: acct.acctsessiontime || 0,
                    },
                });
            }

            if (synced > 0) {
                this.logger.log(`Synced ${synced} active RADIUS sessions`);
            }
        } catch (error) {
            this.logger.error(`Session sync failed: ${error.message}`);
        }
    }

    // ==========================================
    // VOUCHER ACTIVATION — every 30 seconds
    // Detects first-use of UNUSED vouchers via
    // radpostauth and marks them as ACTIVE.
    // No wall-clock timer — time is tracked via
    // radacct (uptime-based).
    // ==========================================

    @Cron('*/30 * * * * *') // Every 30 seconds
    async activateUsedVouchers() {
        try {
            const unusedVouchers = await this.prisma.voucher.findMany({
                where: { status: VoucherStatus.UNUSED },
                select: {
                    id: true,
                    username: true,
                    planType: true,
                    countType: true,
                    duration: true,
                    price: true,
                    router: { select: { userId: true } },
                },
            });

            if (unusedVouchers.length === 0) return;

            for (const voucher of unusedVouchers) {
                const authRecord = await this.prisma.radPostAuth.findFirst({
                    where: {
                        username: voucher.username,
                        reply: 'Access-Accept',
                    },
                });

                if (!authRecord) continue;

                this.logger.log(`First use detected for voucher ${voucher.username} — marking ACTIVE`);

                const now = new Date();
                let expiresAt: Date | undefined;

                if (voucher.countType === CountType.WALL_CLOCK && voucher.duration) {
                    const seconds = voucher.duration * 60;
                    expiresAt = new Date(now.getTime() + seconds * 1000);

                    await this.radiusService.setExpiration(voucher.username, expiresAt);
                    await this.radiusService.setSessionTimeout(voucher.username, seconds);

                    this.logger.log(
                        `WALL_CLOCK voucher ${voucher.username}: expires at ${expiresAt.toISOString()}`,
                    );
                }

                await this.prisma.voucher.update({
                    where: { id: voucher.id },
                    data: {
                        status: VoucherStatus.ACTIVE,
                        activatedAt: now,
                        soldAt: now,
                        ...(expiresAt && { expiresAt }),
                    },
                });

                const existingSale = await this.prisma.sale.findFirst({
                    where: { voucherId: voucher.id },
                });
                if (!existingSale) {
                    await this.prisma.sale.create({
                        data: {
                            amount: voucher.price,
                            voucherId: voucher.id,
                            userId: voucher.router.userId,
                        },
                    });
                }

                this.logger.log(
                    `Voucher ${voucher.username} activated (${voucher.countType}, duration: ${voucher.duration}min)`,
                );
            }
        } catch (error) {
            this.logger.error(`Voucher activation check failed: ${error.message}`);
        }
    }

    // ==========================================
    // VOUCHER EXPIRATION — every minute
    // Checks total uptime from radacct against
    // allowed duration. Expires when used up.
    // ==========================================

    @Cron(CronExpression.EVERY_MINUTE)
    async expireVouchers() {
        try {
            const activeVouchers = await this.prisma.voucher.findMany({
                where: {
                    status: VoucherStatus.ACTIVE,
                    OR: [
                        { duration: { not: null } },
                        { dataLimit: { not: null } },
                    ],
                },
                select: {
                    id: true,
                    username: true,
                    planType: true,
                    duration: true,
                    dataLimit: true,
                    countType: true,
                    activatedAt: true,
                    expiresAt: true,
                    routerId: true,
                    router: {
                        select: {
                            id: true,
                            ipAddress: true,
                            vpnIp: true,
                            apiPort: true,
                            username: true,
                            password: true,
                        },
                    },
                },
            });

            if (activeVouchers.length === 0) return;

            const now = new Date();
            const expired: string[] = [];

            for (const voucher of activeVouchers) {
                let shouldExpire = false;

                // --- Time-based check ---
                if (voucher.duration) {
                    if (voucher.countType === CountType.WALL_CLOCK) {
                        const deadline = voucher.expiresAt
                            ?? (voucher.activatedAt
                                ? new Date(voucher.activatedAt.getTime() + voucher.duration * 60 * 1000)
                                : null);

                        if (deadline && now >= deadline) {
                            shouldExpire = true;
                            this.logger.log(
                                `WALL_CLOCK voucher ${voucher.username} expired (deadline: ${deadline.toISOString()})`,
                            );
                        }
                    } else {
                        const totalUsed = await this.prisma.radAcct.aggregate({
                            where: { username: voucher.username },
                            _sum: { acctsessiontime: true },
                        });

                        const usedSeconds = totalUsed._sum.acctsessiontime || 0;
                        const allowedSeconds = voucher.duration * 60;

                        if (usedSeconds >= allowedSeconds) {
                            shouldExpire = true;
                            this.logger.log(
                                `ONLINE_ONLY voucher ${voucher.username} used ${usedSeconds}s / ${allowedSeconds}s — expiring`,
                            );
                        }
                    }
                }

                // --- Data-based check ---
                if (!shouldExpire && voucher.dataLimit) {
                    const totalBytes = await this.radiusService.getTotalBytes(voucher.username);
                    const usedBytes = totalBytes.bytesIn + totalBytes.bytesOut;

                    if (usedBytes >= voucher.dataLimit) {
                        shouldExpire = true;
                        this.logger.log(
                            `DATA voucher ${voucher.username} used ${usedBytes} / ${voucher.dataLimit} bytes — expiring`,
                        );
                    }
                }

                if (!shouldExpire) continue;

                await this.radiusService.removeRadiusUser(voucher.username);

                try {
                    const decryptedPassword = this.decryptPassword(voucher.router.password);
                    const connection = {
                        host: voucher.router.vpnIp || voucher.router.ipAddress,
                        port: voucher.router.apiPort,
                        username: voucher.router.username,
                        password: decryptedPassword,
                    };

                    const activeSessions = await this.mikrotikApi.getActiveSessions(connection);
                    const userSession = activeSessions.find(
                        (s: any) => s.user === voucher.username,
                    );

                    if (userSession) {
                        await this.mikrotikApi.disconnectUser(connection, userSession['.id']);
                        this.logger.log(`Disconnected expired user ${voucher.username} from MikroTik`);
                    }
                } catch (disconnectError) {
                    this.logger.warn(
                        `Failed to disconnect ${voucher.username} from MikroTik: ${disconnectError.message}`,
                    );
                }

                await this.prisma.voucher.update({
                    where: { id: voucher.id },
                    data: {
                        status: VoucherStatus.EXPIRED,
                        expiresAt: voucher.expiresAt ?? now,
                    },
                });

                expired.push(voucher.username);
            }

            if (expired.length > 0) {
                this.logger.log(`Expired ${expired.length} voucher(s): ${expired.join(', ')}`);
            }
        } catch (error) {
            this.logger.error(`Voucher expiration failed: ${error.message}`);
        }
    }
}
