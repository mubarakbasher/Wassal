import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { PrismaService } from '../prisma/prisma.service';
import { RadiusService } from './radius.service';
import { MikroTikApiService } from '../mikrotik/mikrotik-api.service';
import { VoucherStatus } from '@prisma/client';
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
        const algorithm = 'aes-256-cbc';
        const key = crypto.scryptSync(process.env.JWT_SECRET || 'secret', 'salt', 32);

        const parts = encryptedPassword.split(':');
        const iv = Buffer.from(parts[0], 'hex');
        const encrypted = parts[1];

        const decipher = crypto.createDecipheriv(algorithm, key, iv);
        let decrypted = decipher.update(encrypted, 'hex', 'utf8');
        decrypted += decipher.final('utf8');

        return decrypted;
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

                // Find the router by NAS IP
                const router = await this.prisma.router.findFirst({
                    where: { ipAddress: acct.nasipaddress },
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
                    where: { ipAddress: acct.nasipaddress },
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
            // Find UNUSED vouchers that have RADIUS credentials
            const unusedVouchers = await this.prisma.voucher.findMany({
                where: { status: VoucherStatus.UNUSED },
                select: {
                    id: true,
                    username: true,
                    planType: true,
                    duration: true,
                },
            });

            if (unusedVouchers.length === 0) return;

            for (const voucher of unusedVouchers) {
                // Check if this user has authenticated via RADIUS
                // (radpostauth logs every auth attempt)
                const authRecord = await this.prisma.radPostAuth.findFirst({
                    where: {
                        username: voucher.username,
                        reply: 'Access-Accept',
                    },
                });

                if (!authRecord) continue; // Not yet used

                // Voucher was used! Mark as ACTIVE.
                // No absolute expiresAt — time is tracked via radacct uptime.
                this.logger.log(`First use detected for voucher ${voucher.username} — marking ACTIVE`);

                await this.prisma.voucher.update({
                    where: { id: voucher.id },
                    data: {
                        status: VoucherStatus.ACTIVE,
                        activatedAt: new Date(),
                    },
                });

                this.logger.log(
                    `Voucher ${voucher.username} activated (uptime-based, duration: ${voucher.duration}min)`,
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
            // Find ACTIVE time-based vouchers with a duration limit
            const activeVouchers = await this.prisma.voucher.findMany({
                where: {
                    status: VoucherStatus.ACTIVE,
                    duration: { not: null },
                },
                select: {
                    id: true,
                    username: true,
                    duration: true,
                    routerId: true,
                    router: {
                        select: {
                            id: true,
                            ipAddress: true,
                            apiPort: true,
                            username: true,
                            password: true,
                        },
                    },
                },
            });

            if (activeVouchers.length === 0) return;

            const expired: string[] = [];

            for (const voucher of activeVouchers) {
                // Query radacct for total session time used across all sessions
                const totalUsed = await this.prisma.radAcct.aggregate({
                    where: { username: voucher.username },
                    _sum: { acctsessiontime: true },
                });

                const usedSeconds = totalUsed._sum.acctsessiontime || 0;
                const allowedSeconds = (voucher.duration || 0) * 60;

                if (usedSeconds < allowedSeconds) continue; // Still has time left

                this.logger.log(
                    `Voucher ${voucher.username} used ${usedSeconds}s / ${allowedSeconds}s — expiring`,
                );

                // Remove RADIUS user so FreeRADIUS rejects logins
                await this.radiusService.removeRadiusUser(voucher.username);

                // Disconnect user from MikroTik hotspot
                try {
                    const decryptedPassword = this.decryptPassword(voucher.router.password);
                    const connection = {
                        host: voucher.router.ipAddress,
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

                // Mark voucher as expired
                await this.prisma.voucher.update({
                    where: { id: voucher.id },
                    data: {
                        status: VoucherStatus.EXPIRED,
                        expiresAt: new Date(), // Record when it actually expired
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
