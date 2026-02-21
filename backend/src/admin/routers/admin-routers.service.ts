import { Injectable, NotFoundException, BadRequestException, Logger } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { MikroTikApiService } from '../../mikrotik/mikrotik-api.service';
import { RadiusService } from '../../radius/radius.service';
import { RouterStatus } from '@prisma/client';
import * as crypto from 'crypto';

@Injectable()
export class AdminRoutersService {
    private readonly logger = new Logger(AdminRoutersService.name);

    constructor(
        private prisma: PrismaService,
        private mikrotikApi: MikroTikApiService,
        private radiusService: RadiusService,
    ) { }

    private encryptPassword(password: string): string {
        const algorithm = 'aes-256-cbc';
        const key = crypto.scryptSync(process.env.JWT_SECRET || 'secret', 'salt', 32);
        const iv = crypto.randomBytes(16);
        const cipher = crypto.createCipheriv(algorithm, key, iv);
        let encrypted = cipher.update(password, 'utf8', 'hex');
        encrypted += cipher.final('hex');
        return iv.toString('hex') + ':' + encrypted;
    }

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

    /** Get ALL routers (admin sees everything) */
    async findAll() {
        const routers = await this.prisma.router.findMany({
            select: {
                id: true,
                name: true,
                ipAddress: true,
                apiPort: true,
                username: true,
                password: true,
                description: true,
                location: true,
                status: true,
                lastSeen: true,
                createdAt: true,
                updatedAt: true,
                userId: true,
                user: { select: { name: true, email: true } },
                _count: {
                    select: {
                        vouchers: true,
                        sessions: true,
                    },
                },
            },
            orderBy: { createdAt: 'desc' },
        });

        // Check connectivity for each router
        const routersWithStatus = await Promise.all(
            routers.map(async (router) => {
                try {
                    const decryptedPassword = this.decryptPassword(router.password);
                    const isOnline = await this.mikrotikApi.quickTestConnection({
                        host: router.ipAddress,
                        port: router.apiPort,
                        username: router.username,
                        password: decryptedPassword,
                    });

                    const newStatus = isOnline ? RouterStatus.ONLINE : RouterStatus.OFFLINE;

                    if (router.status !== newStatus) {
                        await this.prisma.router.update({
                            where: { id: router.id },
                            data: {
                                status: newStatus,
                                lastSeen: isOnline ? new Date() : router.lastSeen,
                            },
                        });
                    }

                    const { password: _, ...routerWithoutPassword } = router;
                    return {
                        ...routerWithoutPassword,
                        status: newStatus,
                        lastSeen: isOnline ? new Date() : router.lastSeen,
                    };
                } catch (error) {
                    this.logger.error(`Failed to check status for router ${router.id}: ${error.message}`);
                    const { password: _, ...routerWithoutPassword } = router;
                    return routerWithoutPassword;
                }
            }),
        );

        return routersWithStatus;
    }

    async findOne(id: string) {
        const router = await this.prisma.router.findUnique({
            where: { id },
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
                user: { select: { name: true, email: true } },
                _count: {
                    select: {
                        vouchers: true,
                        sessions: true,
                    },
                },
            },
        });

        if (!router) {
            throw new NotFoundException('Router not found');
        }

        return router;
    }

    /** Admin creates a router (requires assigning to a user) */
    async create(data: any) {
        const { name, ipAddress, apiPort, username, password, description, location, userId } = data;

        // Check for duplicate IP address
        const existingRouter = await this.prisma.router.findFirst({
            where: { ipAddress },
        });
        if (existingRouter) {
            throw new BadRequestException(`A router with IP ${ipAddress} already exists (${existingRouter.name}).`);
        }

        // If no userId provided, find the first user
        let assignUserId = userId;
        if (!assignUserId) {
            const firstUser = await this.prisma.user.findFirst();
            if (!firstUser) {
                throw new BadRequestException('No users exist to assign this router to.');
            }
            assignUserId = firstUser.id;
        }

        // Test connection
        const connectionTest = await this.mikrotikApi.testConnection({
            host: ipAddress,
            port: apiPort || 8728,
            username,
            password,
        });

        if (!connectionTest) {
            throw new BadRequestException('Failed to connect to MikroTik router. Check credentials and network.');
        }

        const encryptedPassword = this.encryptPassword(password);
        const radiusSecret = crypto.randomBytes(16).toString('hex');

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
                userId: assignUserId,
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
            },
        });

        // Full RADIUS auto-configuration
        const radiusWarnings: string[] = [];
        let radiusConfigured = false;

        // Register NAS client in FreeRADIUS
        try {
            await this.radiusService.registerNas(
                router.ipAddress,
                radiusSecret,
                router.name,
                router.description || undefined,
            );
            this.logger.log(`NAS client registered for ${router.name}`);
        } catch (error) {
            radiusWarnings.push(`Failed to register NAS: ${error.message}`);
            this.logger.warn(`Failed to register NAS for ${router.name}: ${error.message}`);
        }

        // Configure RADIUS on the MikroTik router itself
        const radiusServerIp = process.env.RADIUS_SERVER_IP;
        if (radiusServerIp) {
            try {
                const conn = { host: ipAddress, port: apiPort || 8728, username, password };

                // Add RADIUS server entry on the router (works on both v6 and v7)
                const addResult = await this.mikrotikApi.addRadiusServer(conn, radiusServerIp, radiusSecret);
                if (addResult.success) {
                    this.logger.log(`RADIUS server added to router ${router.name}`);
                } else {
                    radiusWarnings.push(`Failed to add RADIUS server: ${addResult.error}`);
                }

                // Enable RADIUS on hotspot profiles (tries v7 path then v6 path)
                const enableResult = await this.mikrotikApi.enableHotspotRadius(conn);
                if (enableResult.success) {
                    radiusConfigured = true;
                    this.logger.log(`RADIUS enabled on hotspot for ${router.name}`);
                } else {
                    radiusWarnings.push(`Failed to enable RADIUS on hotspot: ${enableResult.error}`);
                }

                // Configure hotspot login to HTTP PAP (fixes "did not send challenge response" error)
                const loginResult = await this.mikrotikApi.configureHotspotLogin(conn);
                if (loginResult.success) {
                    this.logger.log(`Hotspot login set to HTTP PAP on ${router.name}`);
                } else {
                    radiusWarnings.push(`Failed to set login method: ${loginResult.error}`);
                }

                // Upload username-only login page (hides password field)
                const pageResult = await this.mikrotikApi.uploadUsernameOnlyLoginPage(conn);
                if (pageResult.success) {
                    this.logger.log(`Username-only login page uploaded to ${router.name}`);
                } else {
                    radiusWarnings.push(`Login page upload failed: ${pageResult.error}`);
                }
            } catch (error) {
                radiusWarnings.push(`Auto RADIUS setup failed: ${error.message}`);
                this.logger.warn(`Auto RADIUS setup failed for ${router.name}: ${error.message}`);
            }
        } else {
            radiusWarnings.push('RADIUS_SERVER_IP not set in environment');
        }

        this.logger.log(`Router ${router.name} (${router.ipAddress}) added by admin`);
        return {
            ...router,
            radiusEnabled: radiusConfigured,
            radiusWarnings: radiusWarnings.length > 0 ? radiusWarnings : undefined,
        };
    }

    async update(id: string, data: any) {
        const existingRouter = await this.prisma.router.findUnique({ where: { id } });
        if (!existingRouter) {
            throw new NotFoundException('Router not found');
        }

        const updateData: any = {};
        const safeFields = ['name', 'ipAddress', 'apiPort', 'username', 'description', 'location', 'status'];
        for (const field of safeFields) {
            if (data[field] !== undefined) {
                updateData[field] = data[field];
            }
        }

        if (data.userId && data.userId !== existingRouter.userId) {
            updateData.user = { connect: { id: data.userId } };
        }

        // If password is provided and hasn't already been encrypted
        if (data.password && typeof data.password === 'string' && !data.password.includes(':')) {
            // Test connection with new credentials
            const testConnection = {
                host: data.ipAddress || existingRouter.ipAddress,
                port: data.apiPort || existingRouter.apiPort,
                username: data.username || existingRouter.username,
                password: data.password,
            };

            const connectionTest = await this.mikrotikApi.testConnection(testConnection);
            if (!connectionTest) {
                throw new BadRequestException('Failed to connect with updated credentials');
            }

            updateData.password = this.encryptPassword(data.password);
        } else if ((data.ipAddress && data.ipAddress !== existingRouter.ipAddress) || (data.username && data.username !== existingRouter.username)) {
            // Test with old password to ensure we can still connect
            const testConnection = {
                host: data.ipAddress || existingRouter.ipAddress,
                port: data.apiPort || existingRouter.apiPort,
                username: data.username || existingRouter.username,
                password: this.decryptPassword(existingRouter.password),
            };
            const connectionTest = await this.mikrotikApi.testConnection(testConnection);
            if (!connectionTest) {
                throw new BadRequestException('Failed to connect to router. Please re-enter the router password.');
            }
        }

        const updatedRouter = await this.prisma.router.update({
            where: { id },
            data: updateData,
            select: {
                id: true,
                name: true,
                ipAddress: true,
                apiPort: true,
                username: true,
                description: true,
                status: true,
                lastSeen: true,
                updatedAt: true,
            },
        });

        // Try to push latest RADIUS configuration to the router
        try {
            const passwordToUse = data.password ? data.password : this.decryptPassword(existingRouter.password);
            const conn = {
                host: updatedRouter.ipAddress,
                port: updatedRouter.apiPort,
                username: updatedRouter.username,
                password: passwordToUse,
            };
            const enableResult = await this.mikrotikApi.enableHotspotRadius(conn, id);
            if (enableResult.success) {
                this.logger.log(`RADIUS config updated on hotspot for ${updatedRouter.name}`);
            } else {
                this.logger.warn(`Failed to update RADIUS config on router ${updatedRouter.name}: ${enableResult.error}`);
            }
        } catch (error) {
            this.logger.warn(`Failed to update RADIUS config on router ${updatedRouter.name}: ${error.message}`);
        }

        return updatedRouter;
    }

    async remove(id: string) {
        const router = await this.prisma.router.findUnique({ where: { id } });
        if (!router) {
            throw new NotFoundException('Router not found');
        }

        // Remove NAS from RADIUS
        await this.radiusService.removeNas(router.ipAddress);

        await this.prisma.router.delete({ where: { id } });

        this.logger.log(`Router ${router.name} deleted by admin`);
        return { message: 'Router deleted successfully' };
    }

    async getMikrotikProfiles(id: string) {
        const router = await this.prisma.router.findUnique({ where: { id } });
        if (!router) {
            throw new NotFoundException('Router not found');
        }

        const decryptedPassword = this.decryptPassword(router.password);

        try {
            return await this.mikrotikApi.getHotspotProfiles({
                host: router.ipAddress,
                port: router.apiPort,
                username: router.username,
                password: decryptedPassword,
            });
        } catch (error) {
            this.logger.error(`Failed to get profiles for router ${id}: ${error.message}`);
            throw new BadRequestException('Failed to fetch hotspot profiles from router');
        }
    }

    /**
     * Configure an existing router's hotspot login page to username-only
     * Sets HTTP PAP and uploads a custom login page
     */
    async configureLoginPage(id: string) {
        const router = await this.prisma.router.findUnique({ where: { id } });
        if (!router) {
            throw new NotFoundException('Router not found');
        }

        const decryptedPassword = this.decryptPassword(router.password);
        const conn = {
            host: router.ipAddress,
            port: router.apiPort,
            username: router.username,
            password: decryptedPassword,
        };

        const warnings: string[] = [];

        // Set login to HTTP PAP
        const loginResult = await this.mikrotikApi.configureHotspotLogin(conn);
        if (loginResult.success) {
            this.logger.log(`Hotspot login set to HTTP PAP on ${router.name}`);
        } else {
            warnings.push(`Failed to set login method: ${loginResult.error}`);
        }

        // Upload username-only login page
        const pageResult = await this.mikrotikApi.uploadUsernameOnlyLoginPage(conn);
        if (pageResult.success) {
            this.logger.log(`Username-only login page uploaded to ${router.name}`);
        } else {
            warnings.push(`Login page upload failed: ${pageResult.error}`);
        }

        return {
            success: loginResult.success || pageResult.success,
            loginMethodConfigured: loginResult.success,
            loginPageUploaded: pageResult.success,
            warnings: warnings.length > 0 ? warnings : undefined,
        };
    }
}
