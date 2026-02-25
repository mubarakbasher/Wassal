import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { PrismaService } from '../prisma/prisma.service';
import { MikroTikApiService, MikroTikConnection } from '../mikrotik/mikrotik-api.service';
import { NotificationsService } from '../notifications/notifications.service';
import { RouterStatus } from '@prisma/client';
import * as crypto from 'crypto';

@Injectable()
export class RouterMonitorService implements OnModuleInit {
    private readonly logger = new Logger(RouterMonitorService.name);
    private isMonitoring = false;

    constructor(
        private prisma: PrismaService,
        private mikrotikApi: MikroTikApiService,
        private notificationsService: NotificationsService,
    ) { }

    onModuleInit() {
        this.logger.log('Router Monitor Service initialized');
        // Run an initial check immediately so routers don't wait 60s for first status update
        setTimeout(() => this.monitorRouters(), 5000);
    }

    // Run every 60 seconds
    @Cron(CronExpression.EVERY_MINUTE)
    async monitorRouters() {
        if (this.isMonitoring) {
            this.logger.debug('Previous monitoring cycle still running, skipping...');
            return;
        }

        this.isMonitoring = true;
        this.logger.log('Starting router status monitoring cycle...');

        try {
            // Get all routers with their owners' notification preferences
            const routers = await this.prisma.router.findMany({
                select: {
                    id: true,
                    name: true,
                    ipAddress: true,
                    vpnIp: true,
                    apiPort: true,
                    username: true,
                    password: true,
                    description: true,
                    status: true,
                    lastSeen: true,
                    userId: true,
                },
            });

            for (const router of routers) {
                const isPending = router.description?.includes('Pending WireGuard setup') && !router.vpnIp;
                await this.checkRouterStatus(router, isPending);
            }

            this.logger.log(`Completed monitoring ${routers.length} routers`);
        } catch (error) {
            this.logger.error(`Monitoring cycle failed: ${error.message}`);
        } finally {
            this.isMonitoring = false;
        }
    }

    private async checkRouterStatus(router: {
        id: string;
        name: string;
        ipAddress: string;
        vpnIp: string | null;
        apiPort: number;
        username: string;
        password: string;
        status: RouterStatus;
        lastSeen: Date | null;
        userId: string;
    }, isPending = false) {
        const previousStatus = router.status;
        let currentStatus: RouterStatus;
        let isReachable = false;

        const connectHost = router.vpnIp || router.ipAddress;

        try {
            const password = this.decryptPassword(router.password);

            const connection: MikroTikConnection = {
                host: connectHost,
                port: router.apiPort,
                username: router.username,
                password: password,
            };

            this.logger.log(`[Monitor] Checking ${router.name}: ${connectHost}:${router.apiPort} (user=${router.username})`);

            isReachable = await this.mikrotikApi.quickTestConnection(connection);
            currentStatus = isReachable
                ? RouterStatus.ONLINE
                : (isPending ? previousStatus : RouterStatus.OFFLINE);

            this.logger.log(`[Monitor] ${router.name}: ${isReachable ? 'ONLINE' : 'OFFLINE'} (was ${previousStatus})`);
        } catch (error) {
            currentStatus = isPending ? previousStatus : RouterStatus.OFFLINE;
            this.logger.warn(`[Monitor] ${router.name} (${connectHost}) check failed: ${error.message}`);
        }

        if (previousStatus !== currentStatus) {
            await this.prisma.router.update({
                where: { id: router.id },
                data: {
                    status: currentStatus,
                    lastSeen: isReachable ? new Date() : router.lastSeen,
                },
            });

            this.logger.log(
                `Router ${router.name} status changed: ${previousStatus} -> ${currentStatus}`,
            );

            const user = await this.prisma.user.findUnique({
                where: { id: router.userId },
                select: { notifyRouterStatus: true },
            });

            if (user?.notifyRouterStatus) {
                await this.notificationsService.sendRouterStatusNotification(
                    router.userId,
                    router.name,
                    currentStatus === RouterStatus.ONLINE,
                    router.id,
                );
            }
        } else if (isReachable) {
            await this.prisma.router.update({
                where: { id: router.id },
                data: { lastSeen: new Date() },
            });
        }
    }

    private decryptPassword(encryptedPassword: string): string {
        try {
            const algorithm = 'aes-256-cbc';
            // Must match the key used for encryption in routers.service.ts
            const key = crypto.scryptSync(process.env.JWT_SECRET || 'secret', 'salt', 32);

            const parts = encryptedPassword.split(':');
            if (parts.length !== 2) {
                return encryptedPassword;
            }

            const iv = Buffer.from(parts[0], 'hex');
            const encrypted = parts[1];
            const decipher = crypto.createDecipheriv(algorithm, key, iv);
            let decrypted = decipher.update(encrypted, 'hex', 'utf8');
            decrypted += decipher.final('utf8');
            return decrypted;
        } catch (error) {
            this.logger.error(`Failed to decrypt password: ${error.message}`);
            return encryptedPassword;
        }
    }
}
