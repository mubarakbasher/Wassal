import { Injectable, NotFoundException, BadRequestException, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { MikroTikApiService } from '../mikrotik/mikrotik-api.service';
import { RadiusService } from '../radius/radius.service';
import { CreateRouterDto, UpdateRouterDto } from './dto/router.dto';
import { RouterStatus } from '@prisma/client';
import * as crypto from 'crypto';

@Injectable()
export class RoutersService {
    private readonly logger = new Logger(RoutersService.name);

    constructor(
        private prisma: PrismaService,
        private mikrotikApi: MikroTikApiService,
        private radiusService: RadiusService,
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

        // Generate a RADIUS secret for this router
        const radiusSecret = crypto.randomBytes(16).toString('hex');

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
                radiusSecret,
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
                radiusSecret: true,
                status: true,
                lastSeen: true,
                createdAt: true,
                updatedAt: true,
            },
        });

        // Register this router as a RADIUS NAS client
        await this.radiusService.registerNas(
            router.ipAddress,
            radiusSecret,
            router.name,
            router.description || undefined,
        );

        // Auto-configure RADIUS on the MikroTik router
        const radiusServerIp = process.env.RADIUS_SERVER_IP;
        if (radiusServerIp) {
            try {
                const conn = {
                    host: ipAddress,
                    port: apiPort || 8728,
                    username,
                    password,
                };

                // Add RADIUS server entry on the router
                const addResult = await this.mikrotikApi.addRadiusServer(conn, radiusServerIp, radiusSecret);
                if (addResult.success) {
                    this.logger.log(`RADIUS server ${radiusServerIp} added to router ${router.name}`);
                } else {
                    this.logger.warn(`Failed to add RADIUS server to ${router.name}: ${addResult.error}`);
                }

                // Enable RADIUS on hotspot server profile
                const enableResult = await this.mikrotikApi.enableHotspotRadius(conn);
                if (enableResult.success) {
                    this.logger.log(`RADIUS enabled on hotspot for router ${router.name}`);
                } else {
                    this.logger.warn(`Failed to enable RADIUS on hotspot for ${router.name}: ${enableResult.error}`);
                }
            } catch (error) {
                this.logger.warn(`Auto RADIUS setup failed for ${router.name}: ${error.message}. You can configure it manually.`);
            }
        } else {
            this.logger.warn('RADIUS_SERVER_IP not set - skipping auto RADIUS configuration on router');
        }

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
     * Includes real-time status check for each router
     */
    async findAll(userId: string) {
        const routers = await this.prisma.router.findMany({
            where: { userId },
            select: {
                id: true,
                name: true,
                ipAddress: true,
                apiPort: true,
                username: true,
                password: true, // Need password for connection test
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

        // Check connectivity for each router in parallel and update status
        const routersWithStatus = await Promise.all(
            routers.map(async (router) => {
                try {
                    const decryptedPassword = this.decryptPassword(router.password);
                    // Use quick test with short timeout for status checks
                    const isOnline = await this.mikrotikApi.quickTestConnection({
                        host: router.ipAddress,
                        port: router.apiPort,
                        username: router.username,
                        password: decryptedPassword,
                    });

                    const newStatus = isOnline ? RouterStatus.ONLINE : RouterStatus.OFFLINE;

                    // Update status in database if changed
                    if (router.status !== newStatus) {
                        await this.prisma.router.update({
                            where: { id: router.id },
                            data: {
                                status: newStatus,
                                lastSeen: isOnline ? new Date() : router.lastSeen,
                            },
                        });
                    }

                    // Return router without password, with updated status
                    const { password: _, ...routerWithoutPassword } = router;
                    return {
                        ...routerWithoutPassword,
                        status: newStatus,
                        lastSeen: isOnline ? new Date() : router.lastSeen,
                    };
                } catch (error) {
                    this.logger.error(`Failed to check status for router ${router.id}: ${error.message}`);
                    // Return router with current status if check fails
                    const { password: _, ...routerWithoutPassword } = router;
                    return routerWithoutPassword;
                }
            })
        );

        return routersWithStatus;
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

        // Remove RADIUS server config from MikroTik router
        const radiusServerIp = process.env.RADIUS_SERVER_IP;
        if (radiusServerIp) {
            try {
                const decryptedPassword = this.decryptPassword(router.password);
                const conn = {
                    host: router.ipAddress,
                    port: router.apiPort,
                    username: router.username,
                    password: decryptedPassword,
                };
                await this.mikrotikApi.removeRadiusServer(conn, radiusServerIp);
                this.logger.log(`RADIUS server removed from router ${router.name}`);
            } catch (error) {
                this.logger.warn(`Failed to remove RADIUS config from ${router.name}: ${error.message}`);
            }
        }

        // Unregister NAS from RADIUS
        await this.radiusService.removeNas(router.ipAddress);

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

        const password = this.decryptPassword(router.password);

        const connection = {
            host: router.ipAddress,
            port: router.apiPort,
            username: router.username,
            password: password,
        };

        // Run DB queries in parallel (fast, no connection limits)
        const now = new Date();
        const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
        const endOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0);

        const [totalVouchersCount, bandwidthAgg, revenueAgg] = await Promise.all([
            this.prisma.voucher.count({ where: { routerId: id } }),
            this.prisma.session.aggregate({
                _sum: { bytesIn: true, bytesOut: true },
                where: { routerId: id },
            }),
            this.prisma.sale.aggregate({
                _sum: { amount: true },
                where: { soldAt: { gte: startOfMonth, lte: endOfMonth } }
            }),
        ]);

        // Run MikroTik calls in PARALLEL with overall timeout
        let isOnline = false;
        let activeSessions: any[] = [];
        let hotspotUsers: any[] = [];
        let uptime = '0s';

        try {
            // Quick test connection first (10 second timeout)
            isOnline = await this.mikrotikApi.quickTestConnection(connection);

            if (isOnline) {
                // Run all MikroTik calls in parallel (no internal timeout - mobile app has 30s timeout)
                try {
                    const [sessions, users, uptimeVal] = await Promise.all([
                        this.mikrotikApi.getActiveSessions(connection).catch(() => []),
                        this.mikrotikApi.getHotspotUsers(connection).catch(() => []),
                        this.mikrotikApi.getUptime(connection).catch(() => '0s'),
                    ]);
                    activeSessions = sessions;
                    hotspotUsers = users;
                    uptime = uptimeVal;
                } catch (dataErr) {
                    this.logger.warn(`MikroTik stats failed for ${connection.host}: ${dataErr.message}`);
                    // Keep isOnline true since connection test succeeded
                }
            }
        } catch (error) {
            this.logger.error(`Failed to get MikroTik stats: ${error.message}`);
            isOnline = false;
        }

        const totalBytes = (BigInt(bandwidthAgg._sum.bytesIn || 0) + BigInt(bandwidthAgg._sum.bytesOut || 0)).toString();

        return {
            routerId: router.id,
            isOnline,
            uptime,
            activeUsers: activeSessions.length,
            totalUsers: hotspotUsers.length,
            totalVouchers: totalVouchersCount,
            totalRevenue: revenueAgg._sum.amount || 0,
            totalBandwidth: totalBytes,
        };
    }

    /**
     * Get hotspot profiles directly from Mikrotik
    /**
     * Get hotspot profiles directly from Mikrotik
     */
    async getMikrotikProfiles(id: string, userId: string) {
        const router = await this.prisma.router.findFirst({
            where: { id, userId },
        });

        if (!router) {
            throw new NotFoundException('Router not found');
        }

        const decryptedPassword = this.decryptPassword(router.password);

        try {
            const profiles = await this.mikrotikApi.getHotspotProfiles({
                host: router.ipAddress,
                port: router.apiPort,
                username: router.username,
                password: decryptedPassword,
            });

            return profiles;
        } catch (error) {
            this.logger.error(`Failed to get profiles for router ${id}: ${error.message}`);
            throw new BadRequestException('Failed to fetch hotspot profiles from router');
        }
    }

    /**
     * Create a new hotspot profile on MikroTik
     */
    async createMikrotikProfile(
        id: string,
        userId: string,
        profileData: {
            name: string;
            rateLimit?: string;
            sessionTimeout?: string;
            limitUptime?: string;
            sharedUsers?: number;
            idleTimeout?: string;
            keepaliveTimeout?: string;
            useSchedulerTime?: boolean;
            schedulerInterval?: string;
        }
    ) {
        const router = await this.prisma.router.findFirst({
            where: { id, userId },
        });

        if (!router) {
            throw new NotFoundException('Router not found');
        }

        const decryptedPassword = this.decryptPassword(router.password);

        try {
            const result = await this.mikrotikApi.createHotspotProfile(
                {
                    host: router.ipAddress,
                    port: router.apiPort,
                    username: router.username,
                    password: decryptedPassword,
                },
                profileData
            );

            if (!result.success) {
                throw new BadRequestException(result.error || 'Failed to create profile');
            }

            return { success: true, message: 'Profile created successfully' };
        } catch (error) {
            this.logger.error(`Failed to create profile on router ${id}: ${error.message}`);
            throw new BadRequestException(error.message || 'Failed to create hotspot profile');
        }
    }

    /**
     * Handle router script callback (Auto-Discovery)
     * @param ip - Router IP address
     * @param userId - Optional user ID to assign the router to
     */
    async handleScriptCallback(ip: string, userId?: string) {
        this.logger.log(`Received script callback from IP: ${ip}, userId: ${userId || 'not provided'}`);

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
            // If router exists and userId is provided and different, update the owner
            if (userId && existing.userId !== userId) {
                // Verify the new user exists
                const newOwner = await this.prisma.user.findUnique({
                    where: { id: userId }
                });

                if (newOwner) {
                    // Reassign router to the new user
                    await this.prisma.router.update({
                        where: { id: existing.id },
                        data: { userId: newOwner.id }
                    });

                    this.logger.log(`Router at ${ip} reassigned from user ${existing.userId} to user ${userId}`);
                    return {
                        message: 'Router reassigned to your account',
                        routerId: existing.id,
                        userId: userId
                    };
                }
            }

            // Router already belongs to this user or no userId provided
            this.logger.log(`Router at ${ip} already exists with id: ${existing.id}`);
            return { message: 'Router already registered', routerId: existing.id, userId: existing.userId };
        }

        // 3. Find the user to assign router to
        let assignToUser;

        if (userId) {
            // Use provided userId
            assignToUser = await this.prisma.user.findUnique({
                where: { id: userId }
            });

            if (!assignToUser) {
                this.logger.warn(`User ${userId} not found, falling back to first user`);
            }
        }

        // Fallback: Find first user if no userId provided or user not found
        if (!assignToUser) {
            assignToUser = await this.prisma.user.findFirst();
        }

        if (!assignToUser) {
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
                userId: assignToUser.id,
            }
        });

        // Log activity
        await this.prisma.activityLog.create({
            data: {
                userId: assignToUser.id,
                action: 'ROUTER_ADDED',
                details: JSON.stringify({
                    routerId: router.id,
                    name: router.name,
                    ipAddress: router.ipAddress,
                    method: 'script-auto-discovery'
                }),
            },
        });

        this.logger.log(`Auto-registered router: ${router.name} (${router.id}) for user ${assignToUser.id}`);
        return { message: 'Router registered successfully', routerId: router.id, userId: assignToUser.id };
    }

    /**
     * Get active hotspot users from router
     */
    async getActiveUsers(id: string, userId: string) {
        const router = await this.prisma.router.findFirst({
            where: { id, userId },
        });

        if (!router) {
            throw new NotFoundException('Router not found');
        }

        const decryptedPassword = this.decryptPassword(router.password);

        try {
            const sessions = await this.mikrotikApi.getActiveSessions({
                host: router.ipAddress,
                port: router.apiPort,
                username: router.username,
                password: decryptedPassword,
            });

            // Format sessions for frontend
            return sessions.map(session => ({
                id: session['.id'],
                username: session.user || 'Unknown',
                macAddress: session['mac-address'] || 'N/A',
                ipAddress: session.address || 'N/A',
                uptime: session.uptime || '0s',
                bytesIn: parseInt(session['bytes-in'] || '0'),
                bytesOut: parseInt(session['bytes-out'] || '0'),
                status: 'active',
            }));
        } catch (error) {
            this.logger.error(`Failed to get active users for router ${id}: ${error.message}`);
            return [];
        }
    }

    /**
     * Get router interfaces
     */
    async getInterfaces(id: string, userId: string) {
        const router = await this.prisma.router.findFirst({
            where: { id, userId },
        });

        if (!router) {
            throw new NotFoundException('Router not found');
        }

        const decryptedPassword = this.decryptPassword(router.password);

        try {
            const interfaces = await this.mikrotikApi.getInterfaces({
                host: router.ipAddress,
                port: router.apiPort,
                username: router.username,
                password: decryptedPassword,
            });

            // Format interfaces for frontend
            return interfaces.map(iface => ({
                id: iface['.id'],
                name: iface.name || 'Unknown',
                type: iface.type || 'unknown',
                status: iface.running === 'true' ? 'up' : 'down',
                disabled: iface.disabled === 'true',
                txBytes: parseInt(iface['tx-byte'] || '0'),
                rxBytes: parseInt(iface['rx-byte'] || '0'),
                macAddress: iface['mac-address'] || 'N/A',
            }));
        } catch (error) {
            this.logger.error(`Failed to get interfaces for router ${id}: ${error.message}`);
            return [];
        }
    }

    /**
     * Get router system logs
     */
    async getRouterLogs(id: string, userId: string, limit: number = 50) {
        const router = await this.prisma.router.findFirst({
            where: { id, userId },
        });

        if (!router) {
            throw new NotFoundException('Router not found');
        }

        const decryptedPassword = this.decryptPassword(router.password);

        try {
            const logs = await this.mikrotikApi.getSystemLogs(
                {
                    host: router.ipAddress,
                    port: router.apiPort,
                    username: router.username,
                    password: decryptedPassword,
                },
                limit
            );

            // Format logs for frontend
            return logs.map(log => ({
                id: log['.id'],
                time: log.time || '',
                topics: log.topics || '',
                message: log.message || '',
            }));
        } catch (error) {
            this.logger.error(`Failed to get logs for router ${id}: ${error.message}`);
            return [];
        }
    }

    /**
     * Disconnect a hotspot user
     */
    async disconnectUser(routerId: string, sessionId: string, userId: string) {
        const router = await this.prisma.router.findFirst({
            where: { id: routerId, userId },
        });

        if (!router) {
            throw new NotFoundException('Router not found');
        }

        const decryptedPassword = this.decryptPassword(router.password);

        try {
            const result = await this.mikrotikApi.disconnectUser(
                {
                    host: router.ipAddress,
                    port: router.apiPort,
                    username: router.username,
                    password: decryptedPassword,
                },
                sessionId
            );

            if (result.success) {
                return { message: 'User disconnected successfully' };
            } else {
                throw new BadRequestException(result.error || 'Failed to disconnect user');
            }
        } catch (error) {
            this.logger.error(`Failed to disconnect user: ${error.message}`);
            throw new BadRequestException('Failed to disconnect user');
        }
    }

    /**
     * Restart router
     */
    async restartRouter(id: string, userId: string) {
        const router = await this.prisma.router.findFirst({
            where: { id, userId },
        });

        if (!router) {
            throw new NotFoundException('Router not found');
        }

        const decryptedPassword = this.decryptPassword(router.password);

        try {
            const result = await this.mikrotikApi.rebootRouter({
                host: router.ipAddress,
                port: router.apiPort,
                username: router.username,
                password: decryptedPassword,
            });

            // Log activity
            await this.prisma.activityLog.create({
                data: {
                    userId,
                    action: 'ROUTER_RESTART',
                    details: JSON.stringify({ routerId: id, name: router.name }),
                },
            });

            return { message: 'Router restart initiated' };
        } catch (error) {
            this.logger.error(`Failed to restart router ${id}: ${error.message}`);
            throw new BadRequestException('Failed to restart router');
        }
    }
}

