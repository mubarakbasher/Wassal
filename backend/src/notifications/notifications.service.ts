import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import * as admin from 'firebase-admin';
import * as fs from 'fs';
import * as path from 'path';

@Injectable()
export class NotificationsService {
    private readonly logger = new Logger(NotificationsService.name);
    private firebaseInitialized = false;

    constructor(private prisma: PrismaService) {
        this.initializeFirebase();
    }

    private initializeFirebase() {
        // Try to initialize from environment variable first
        const credentials = process.env.FIREBASE_CREDENTIALS;
        if (credentials) {
            try {
                const serviceAccount = JSON.parse(credentials);
                admin.initializeApp({
                    credential: admin.credential.cert(serviceAccount),
                });
                this.firebaseInitialized = true;
                this.logger.log('Firebase Admin SDK initialized from environment variable');
                return;
            } catch (error) {
                this.logger.warn('Failed to parse FIREBASE_CREDENTIALS: ' + error.message);
            }
        }

        // Try to load from file in the backend root directory
        const possibleFiles = [
            'wassal-2d866-firebase-adminsdk-fbsvc-dcd19660bd.json',
            'firebase-credentials.json',
            'serviceAccountKey.json',
        ];

        for (const fileName of possibleFiles) {
            const filePath = path.join(process.cwd(), fileName);
            if (fs.existsSync(filePath)) {
                try {
                    const serviceAccount = JSON.parse(fs.readFileSync(filePath, 'utf8'));
                    admin.initializeApp({
                        credential: admin.credential.cert(serviceAccount),
                    });
                    this.firebaseInitialized = true;
                    this.logger.log(`Firebase Admin SDK initialized from file: ${fileName}`);
                    return;
                } catch (error) {
                    this.logger.warn(`Failed to load Firebase credentials from ${fileName}: ${error.message}`);
                }
            }
        }

        this.logger.warn('Firebase credentials not found - push notifications disabled');
    }

    // Register a device token for a user
    async registerToken(userId: string, token: string, platform: 'android' | 'ios') {
        // Upsert - update if exists, create if not
        await this.prisma.deviceToken.upsert({
            where: { token },
            update: { userId, platform, updatedAt: new Date() },
            create: { token, platform, userId },
        });
        this.logger.log(`Registered device token for user ${userId} (${platform})`);
    }

    // Remove a device token
    async removeToken(token: string) {
        await this.prisma.deviceToken.deleteMany({
            where: { token },
        });
    }

    // Send notification to a specific user
    async sendToUser(userId: string, title: string, body: string, data?: Record<string, string>) {
        if (!this.firebaseInitialized) {
            this.logger.warn('Firebase not initialized - skipping notification');
            return;
        }

        const tokens = await this.prisma.deviceToken.findMany({
            where: { userId },
            select: { token: true },
        });

        if (tokens.length === 0) {
            this.logger.debug(`No device tokens found for user ${userId}`);
            return;
        }

        const message: admin.messaging.MulticastMessage = {
            tokens: tokens.map(t => t.token),
            notification: {
                title,
                body,
            },
            data: data || {},
            android: {
                priority: 'high',
                notification: {
                    channelId: 'router_status',
                    priority: 'high',
                },
            },
            apns: {
                payload: {
                    aps: {
                        sound: 'default',
                        badge: 1,
                    },
                },
            },
        };

        try {
            const response = await admin.messaging().sendEachForMulticast(message);
            this.logger.log(`Sent notification to ${response.successCount}/${tokens.length} devices for user ${userId}`);

            // Clean up invalid tokens
            if (response.failureCount > 0) {
                const invalidTokens: string[] = [];
                response.responses.forEach((resp, idx) => {
                    if (!resp.success) {
                        invalidTokens.push(tokens[idx].token);
                    }
                });
                if (invalidTokens.length > 0) {
                    await this.prisma.deviceToken.deleteMany({
                        where: { token: { in: invalidTokens } },
                    });
                    this.logger.log(`Cleaned up ${invalidTokens.length} invalid tokens`);
                }
            }
        } catch (error) {
            this.logger.error(`Failed to send notification: ${error.message}`);
        }
    }

    // Send router status notification
    async sendRouterStatusNotification(
        userId: string,
        routerName: string,
        isOnline: boolean,
        routerId: string,
    ) {
        const title = isOnline ? '🟢 Router Online' : '🔴 Router Offline';
        const body = isOnline
            ? `${routerName} is back online and ready to use.`
            : `${routerName} has gone offline. Please check the connection.`;

        await this.sendToUser(userId, title, body, {
            type: 'router_status',
            routerId,
            status: isOnline ? 'online' : 'offline',
        });
    }
}
