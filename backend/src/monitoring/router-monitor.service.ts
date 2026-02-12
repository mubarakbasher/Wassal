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
    }

    // Run every 60 seconds
    @Cron(CronExpression.EVERY_MINUTE)
    async monitorRouters() {
        if (this.isMonitoring) {
            this.logger.debug('Previous monitoring cycle still running, skipping...');
            return;
        }

        this.isMonitoring = true;
        this.logger.debug('Starting router status monitoring cycle...');

        try {
            // Get all routers with their owners' notification preferences
            const routers = await this.prisma.router.findMany({
                select: {
                    id: true,
                    name: true,
                    ipAddress: true,
                    apiPort: true,
                    username: true,
                    password: true,
                    status: true,
                    lastSeen: true,
                    userId: true,
                },
            });

            for (const router of routers) {
                await this.checkRouterStatus(router);
            }

            this.logger.debug(`Completed monitoring ${routers.length} routers`);
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
        apiPort: number;
        username: string;
        password: string;
        status: RouterStatus;
        lastSeen: Date | null;
        userId: string;
    }) {
        const previousStatus = router.status;
        let currentStatus: RouterStatus;
        let isReachable = false;

        try {
            // Decrypt the password
            const password = this.decryptPassword(router.password);

            // Create connection object
            const connection: MikroTikConnection = {
                host: router.ipAddress,
                port: router.apiPort,
                username: router.username,
                password: password,
            };

            // Use quick test connection
            isReachable = await this.mikrotikApi.quickTestConnection(connection);
            currentStatus = isReachable ? RouterStatus.ONLINE : RouterStatus.OFFLINE;
        } catch (error) {
            // Connection failed
            currentStatus = RouterStatus.OFFLINE;
            this.logger.debug(`Router ${router.name} (${router.ipAddress}) check failed: ${error.message}`);
        }

        // Update status in database if changed
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

            // Get user's notification preference
            const user = await this.prisma.user.findUnique({
                where: { id: router.userId },
                select: { notifyRouterStatus: true },
            });

            // Send notification if user has notifications enabled
            if (user?.notifyRouterStatus) {
                await this.notificationsService.sendRouterStatusNotification(
                    router.userId,
                    router.name,
                    currentStatus === RouterStatus.ONLINE,
                    router.id,
                );
            }
        } else if (isReachable) {
            // Update lastSeen even if status didn't change
            await this.prisma.router.update({
                where: { id: router.id },
                data: { lastSeen: new Date() },
            });
        }
    }

    private decryptPassword(encryptedPassword: string): string {
        try {
            const algorithm = 'aes-256-cbc';
            const key = process.env.ENCRYPTION_KEY || 'default-encryption-key-change-me!';
            const keyBuffer = crypto.scryptSync(key, 'salt', 32);

            const parts = encryptedPassword.split(':');
            if (parts.length !== 2) {
                return encryptedPassword;
            }

            const iv = Buffer.from(parts[0], 'hex');
            const encryptedText = Buffer.from(parts[1], 'hex');
            const decipher = crypto.createDecipheriv(algorithm, keyBuffer, iv);
            let decrypted = decipher.update(encryptedText);
            decrypted = Buffer.concat([decrypted, decipher.final()]);
            return decrypted.toString();
        } catch (error) {
            return encryptedPassword;
        }
    }
}
