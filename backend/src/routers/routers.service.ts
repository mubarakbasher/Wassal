import { Injectable, NotFoundException, BadRequestException, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { MikroTikApiService } from '../mikrotik/mikrotik-api.service';
import { CreateRouterDto, UpdateRouterDto } from './dto/router.dto';
import { RouterStatus } from '@prisma/client';
import * as crypto from 'crypto';

@Injectable()
export class RoutersService {
    private readonly logger = new Logger(RoutersService.name);

    constructor(
        private prisma: PrismaService,
        private mikrotikApi: MikroTikApiService,
    ) { }

    /**
     * Encrypt router password for storage
     */
    private encryptPassword(password: string): string {
        const algorithm = 'aes-256-cbc';
        const key = crypto.scryptSync(process.env.JWT_SECRET || 'secret', 'salt', 32);
        const iv = crypto.randomBytes(16);

        const cipher = crypto.createCipheriv(algorithm, key, iv);
        let encrypted = cipher.update(password, 'utf8', 'hex');
        encrypted += cipher.final('hex');

        return iv.toString('hex') + ':' + encrypted;
    }

    /**
     * Decrypt router password
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

    /**
     * Create a new router
     */
    async create(userId: string, createRouterDto: CreateRouterDto) {
        const { name, ipAddress, apiPort, username, password, description, location } = createRouterDto;

        // Test connection before saving
        const connectionTest = await this.mikrotikApi.testConnection({
            host: ipAddress,
            port: apiPort || 8728,
            username,
            password,
        });

        if (!connectionTest) {
            throw new BadRequestException('Failed to connect to MikroTik router. Please check credentials and network connectivity.');
        }

        // Encrypt password
        const encryptedPassword = this.encryptPassword(password);

        // Create router
        const router = await this.prisma.router.create({
            data: {
                name,
                ipAddress,
                apiPort: apiPort || 8728,
                username,
                password: encryptedPassword,
                description,
                location,
                status: RouterStatus.ONLINE,
                lastSeen: new Date(),
                userId,
            },
            select: {
                id: true,
                name: true,
                ipAddress: true,
                apiPort: true,
                username: true,
                description: true,
                location: true,
                status: true,
                lastSeen: true,
                createdAt: true,
                updatedAt: true,
            },
        });

        // Log activity
        await this.prisma.activityLog.create({
            data: {
                userId,
                action: 'ROUTER_ADDED',
                details: JSON.stringify({ routerId: router.id, name: router.name, ipAddress: router.ipAddress }),
            },
        });

        this.logger.log(`Router ${router.name} (${router.ipAddress}) added by user ${userId}`);

        return router;
    }

    /**
     * Get all routers for a user
     */
    async findAll(userId: string) {
        return this.prisma.router.findMany({
            where: { userId },
            select: {
                id: true,
                name: true,
                ipAddress: true,
                apiPort: true,
                username: true,
                description: true,
                location: true,
                status: true,
                lastSeen: true,
                createdAt: true,
                updatedAt: true,
                _count: {
                    select: {
                        vouchers: true,
                        sessions: true,
                    },
                },
            },
            orderBy: { createdAt: 'desc' },
        });
    }

    /**
     * Get a single router
     */
    async findOne(id: string, userId: string) {
        const router = await this.prisma.router.findFirst({
            where: { id, userId },
            select: {
                id: true,
                name: true,
                ipAddress: true,
                apiPort: true,
                username: true,
                description: true,
                location: true,
                status: true,
                lastSeen: true,
                createdAt: true,
                updatedAt: true,
                _count: {
                    select: {
                        vouchers: true,
                        sessions: true,
                        hotspotProfiles: true,
                    },
                },
            },
        });

        if (!router) {
            throw new NotFoundException('Router not found');
        }

        return router;
    }

    /**
     * Update a router
     */
    async update(id: string, userId: string, updateRouterDto: UpdateRouterDto) {
        // Check if router exists and belongs to user
        const existingRouter = await this.prisma.router.findFirst({
            where: { id, userId },
        });

        if (!existingRouter) {
            throw new NotFoundException('Router not found');
        }

        // If credentials are being updated, test connection
        if (updateRouterDto.ipAddress || updateRouterDto.username || updateRouterDto.password) {
            const testConnection = {
                host: updateRouterDto.ipAddress || existingRouter.ipAddress,
                port: updateRouterDto.apiPort || existingRouter.apiPort,
                username: updateRouterDto.username || existingRouter.username,
                password: updateRouterDto.password || this.decryptPassword(existingRouter.password),
            };

            const connectionTest = await this.mikrotikApi.testConnection(testConnection);

            if (!connectionTest) {
                throw new BadRequestException('Failed to connect with updated credentials');
            }
        }

        // Prepare update data
        const updateData: any = { ...updateRouterDto };

        // Encrypt password if provided
        if (updateRouterDto.password) {
            updateData.password = this.encryptPassword(updateRouterDto.password);
        }

        // Update router
        const router = await this.prisma.router.update({
            where: { id },
            data: updateData,
            select: {
                id: true,
                name: true,
                ipAddress: true,
                apiPort: true,
                username: true,
                description: true,
                location: true,
                status: true,
                lastSeen: true,
                updatedAt: true,
            },
        });

        // Log activity
        await this.prisma.activityLog.create({
            data: {
                userId,
                action: 'ROUTER_UPDATED',
                details: JSON.stringify({ routerId: router.id, name: router.name }),
            },
        });

        return router;
    }

    /**
     * Delete a router
     */
    async remove(id: string, userId: string) {
        // Check if router exists and belongs to user
        const router = await this.prisma.router.findFirst({
            where: { id, userId },
        });

        if (!router) {
            throw new NotFoundException('Router not found');
        }

        // Delete router (cascade will handle related records)
        await this.prisma.router.delete({
            where: { id },
        });

        // Log activity
        await this.prisma.activityLog.create({
            data: {
                userId,
                action: 'ROUTER_DELETED',
                details: JSON.stringify({ routerId: id, name: router.name }),
            },
        });

        this.logger.log(`Router ${router.name} deleted by user ${userId}`);

        return { message: 'Router deleted successfully' };
    }

    /**
     * Check router health/connectivity
     */
    async checkHealth(id: string, userId: string) {
        const router = await this.prisma.router.findFirst({
            where: { id, userId },
        });

        if (!router) {
            throw new NotFoundException('Router not found');
        }

        const decryptedPassword = this.decryptPassword(router.password);

        const isOnline = await this.mikrotikApi.testConnection({
            host: router.ipAddress,
            port: router.apiPort,
            username: router.username,
            password: decryptedPassword,
        });

        // Update router status
        const newStatus = isOnline ? RouterStatus.ONLINE : RouterStatus.OFFLINE;

        await this.prisma.router.update({
            where: { id },
            data: {
                status: newStatus,
                lastSeen: isOnline ? new Date() : router.lastSeen,
            },
        });

        return {
            routerId: id,
            name: router.name,
            status: newStatus,
            isOnline,
            lastSeen: isOnline ? new Date() : router.lastSeen,
        };
    }

    /**
     * Get router system information
     */
    async getSystemInfo(id: string, userId: string) {
        const router = await this.prisma.router.findFirst({
            where: { id, userId },
        });

        if (!router) {
            throw new NotFoundException('Router not found');
        }

        const decryptedPassword = this.decryptPassword(router.password);

        try {
            const systemInfo = await this.mikrotikApi.getSystemInfo({
                host: router.ipAddress,
                port: router.apiPort,
                username: router.username,
                password: decryptedPassword,
            });

            // Update last seen
            await this.prisma.router.update({
                where: { id },
                data: {
                    status: RouterStatus.ONLINE,
                    lastSeen: new Date(),
                },
            });

            return systemInfo;
        } catch (error) {
            // Update status to offline
            await this.prisma.router.update({
                where: { id },
                data: { status: RouterStatus.ERROR },
            });

            throw new BadRequestException('Failed to get system information from router');
        }
    }

    async getRouterStats(id: string, userId: string) {
        // Find router with password
        const router = await this.prisma.router.findFirst({
            where: { id, userId },
        });

        if (!router) {
            throw new NotFoundException('Router not found');
        }

        const password = await this.decryptPassword(router.password);

        const connection = {
            host: router.ipAddress,
            port: router.apiPort,
            username: router.username,
            password: password,
        };

        const [isOnline, activeSessions, hotspotUsers, uptime, totalVouchersCount] = await Promise.all([
            this.mikrotikApi.testConnection(connection),
            this.mikrotikApi.getActiveSessions(connection).catch(() => []),
            this.mikrotikApi.getHotspotUsers(connection).catch(() => []),
            this.mikrotikApi.getUptime(connection).catch(() => '0s'),
            this.prisma.voucher.count(),
        ]);

        // Calculate Revenue (Total Sales for current month)
        const now = new Date();
        const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
        const endOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0);

        const revenueAgg = await this.prisma.sale.aggregate({
            _sum: {
                amount: true,
            },
            where: {
                soldAt: {
                    gte: startOfMonth,
                    lte: endOfMonth,
                }
            }
        });

        return {
            routerId: router.id,
            isOnline,
            uptime,
            activeUsers: activeSessions.length,
            totalUsers: hotspotUsers.length,
            totalVouchers: totalVouchersCount,
            totalRevenue: revenueAgg._sum.amount || 0,
        };
    }

    /**
     * Handle router script callback (Auto-Discovery)
     */
    async handleScriptCallback(ip: string) {
        this.logger.log(`Received script callback from IP: ${ip}`);

        const credentials = {
            host: ip,
            port: 8728,
            username: 'wassal_auto',
            password: 'Wassal@123',
        };

        // 1. Validate connection
        const isConnected = await this.mikrotikApi.testConnection(credentials);

        if (!isConnected) {
            this.logger.warn(`Failed to connect to router at ${ip} with script credentials.`);
            throw new BadRequestException(`Unable to connect to router at ${ip}`);
        }

        // 2. Check if already exists
        const existing = await this.prisma.router.findFirst({
            where: { ipAddress: ip }
        });

        if (existing) {
            this.logger.log(`Router at ${ip} already exists.`);
            return { message: 'Router already registered', routerId: existing.id };
        }

        // 3. Create Router (Assign to first admin or make it "Unassigned" to be claimed?)
        // For simplicity, we will assign it to the first user found or a specific admin.
        // Or better: Leave userId optional? No, schema likely requires it.
        // Let's Find the first user for now (or a specific 'admin' if we had that logic).
        const adminUser = await this.prisma.user.findFirst();
        if (!adminUser) {
            throw new BadRequestException("No user found to assign router to.");
        }

        const encryptedPassword = this.encryptPassword(credentials.password);

        const router = await this.prisma.router.create({
            data: {
                name: `Auto-Discovered [${ip}]`,
                ipAddress: ip,
                apiPort: 8728,
                username: credentials.username,
                password: encryptedPassword,
                description: 'Added via Script Auto-Discovery',
                location: 'Unknown',
                status: RouterStatus.ONLINE,
                lastSeen: new Date(),
                userId: adminUser.id,
            }
        });

        this.logger.log(`Auto-registered router: ${router.name} (${router.id})`);
        return { message: 'Router registered successfully', routerId: router.id };
    }
}
