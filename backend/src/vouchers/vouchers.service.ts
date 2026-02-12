import { Injectable, NotFoundException, BadRequestException, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { MikroTikApiService } from '../mikrotik/mikrotik-api.service';
import { RoutersService } from '../routers/routers.service';
import { RadiusService } from '../radius/radius.service';
import { CreateVoucherDto, VoucherFilterDto, VoucherCharset, VoucherAuthType } from './dto/voucher.dto';
import { PlanType, VoucherStatus } from '@prisma/client';
import * as crypto from 'crypto';

@Injectable()
export class VouchersService {
    private readonly logger = new Logger(VouchersService.name);

    constructor(
        private prisma: PrismaService,
        private mikrotikApi: MikroTikApiService,
        private routersService: RoutersService,
        private radiusService: RadiusService,
    ) { }

    /**
     * Get characters based on charset
     */
    private getCharsetString(charset: VoucherCharset): string {
        switch (charset) {
            case VoucherCharset.NUMERIC:
                return '0123456789';
            case VoucherCharset.ALPHA:
                return 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz';
            case VoucherCharset.ALPHANUMERIC:
            default:
                return 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
        }
    }

    /**
     * Generate random string
     */
    private generateRandomString(length: number, charset: VoucherCharset): string {
        const chars = this.getCharsetString(charset);
        let result = '';
        for (let i = 0; i < length; i++) {
            result += chars.charAt(Math.floor(Math.random() * chars.length));
        }
        return result;
    }

    /**
     * Calculate expiration date based on plan type
     */
    private calculateExpiration(planType: PlanType, duration?: number): Date | null {
        if (planType === PlanType.TIME_BASED && duration) {
            const now = new Date();
            return new Date(now.getTime() + duration * 60 * 1000);
        }
        return null;
    }

    /**
     * Format duration for MikroTik (HH:MM:SS)
     */
    private formatDuration(minutes: number): string {
        const hours = Math.floor(minutes / 60);
        const mins = minutes % 60;
        const secs = 0;

        const pad = (num: number) => num.toString().padStart(2, '0');

        return `${pad(hours)}:${pad(mins)}:${pad(secs)}`;
    }

    /**
     * Create a single voucher or bulk vouchers
     */
    async create(userId: string, createVoucherDto: CreateVoucherDto) {
        const {
            routerId,
            profileId,
            mikrotikProfile,
            planType,
            planName,
            duration,
            dataLimit,
            price,
            quantity,
            charset = VoucherCharset.NUMERIC,
            authType = VoucherAuthType.USER_SAME_PASS
        } = createVoucherDto;

        // Verify router exists and belongs to user
        const router = await this.prisma.router.findFirst({
            where: { id: routerId, userId },
        });

        if (!router) {
            throw new NotFoundException('Router not found');
        }

        let targetProfileId = profileId;

        // If mikrotikProfile is provided, try to find it or create a local copy
        if (mikrotikProfile) {
            const existingProfile = await this.prisma.hotspotProfile.findFirst({
                where: {
                    routerId,
                    name: mikrotikProfile,
                },
            });

            if (existingProfile) {
                targetProfileId = existingProfile.id;
            } else {
                // Auto-create local profile wrapper
                // We default to some values since we might not have full details yet, 
                // but the critical part is the name matching the router's profile.
                const newProfile = await this.prisma.hotspotProfile.create({
                    data: {
                        name: mikrotikProfile,
                        routerId,
                        sharedUsers: 1, // Default
                    },
                });
                targetProfileId = newProfile.id;
            }
        }

        if (!targetProfileId) {
            throw new BadRequestException('Either profileId or mikrotikProfile must be provided');
        }

        // Verify profile exists (double check if passed by ID)
        const profile = await this.prisma.hotspotProfile.findFirst({
            where: { id: targetProfileId, routerId },
        });

        if (!profile) {
            throw new NotFoundException('Hotspot profile not found');
        }

        // Validate plan type requirements
        if (planType === PlanType.TIME_BASED && !duration) {
            throw new BadRequestException('Duration is required for time-based plans');
        }

        if (planType === PlanType.DATA_BASED && !dataLimit) {
            throw new BadRequestException('Data limit is required for data-based plans');
        }

        const vouchers: any[] = [];
        const voucherCount = quantity || 1;

        // Ensure the RADIUS group exists for this profile with correct attributes
        const groupName = `${profile.name}_${routerId.substring(0, 8)}`;
        await this.radiusService.upsertGroup(groupName, {
            rateLimit: profile.rateLimit || undefined,
            sharedUsers: profile.sharedUsers,
        });

        // Generate vouchers
        for (let i = 0; i < voucherCount; i++) {
            const username = this.generateRandomString(8, charset);
            let password = '';

            if (authType === VoucherAuthType.USER_SAME_PASS) {
                password = username;
            } else if (authType === VoucherAuthType.USERNAME_ONLY) {
                password = "";
            } else {
                password = this.generateRandomString(8, charset);
            }

            try {
                // Create RADIUS user in database (replaces MikroTik hotspot user)
                await this.radiusService.createRadiusUser(username, password, groupName);

                // Set time-based expiration (real-time countdown)
                if (planType === PlanType.TIME_BASED && duration) {
                    const expiresAt = new Date(Date.now() + duration * 60 * 1000);
                    await this.radiusService.setExpiration(username, expiresAt);
                    // Set Session-Timeout as remaining seconds for MikroTik
                    await this.radiusService.setSessionTimeout(username, duration * 60);
                }

                // Set data limit if applicable
                if (dataLimit) {
                    await this.radiusService.setUserReplyAttribute(
                        username, 'Mikrotik-Total-Limit', dataLimit.toString(),
                    );
                }

            } catch (e) {
                this.logger.error(`Error creating RADIUS user ${username}: ${e.message}`);
                throw new BadRequestException('Failed to create RADIUS user for voucher.');
            }

            // Create voucher in database
            const voucher = await this.prisma.voucher.create({
                data: {
                    username,
                    password,
                    planType,
                    planName,
                    duration,
                    dataLimit: dataLimit ? BigInt(dataLimit) : null,
                    price,
                    status: VoucherStatus.ACTIVE,
                    profileId: targetProfileId!,
                    routerId,
                    activatedAt: new Date(),
                    expiresAt: this.calculateExpiration(planType, duration),
                },
                select: {
                    id: true,
                    username: true,
                    password: true,
                    planType: true,
                    planName: true,
                    duration: true,
                    dataLimit: true,
                    price: true,
                    status: true,
                    createdAt: true,
                    profile: {
                        select: {
                            name: true,
                        },
                    },
                },
            });

            vouchers.push({
                ...voucher,
                dataLimit: voucher.dataLimit ? Number(voucher.dataLimit) : null,
            });
        }

        // Log activity
        await this.prisma.activityLog.create({
            data: {
                userId,
                action: 'VOUCHERS_GENERATED',
                details: JSON.stringify({
                    routerId,
                    count: voucherCount,
                    planName,
                    planType,
                }),
            },
        });

        this.logger.log(`Generated ${voucherCount} voucher(s) for router ${routerId} by user ${userId}`);

        return {
            count: voucherCount,
            vouchers,
        };
    }

    /**
     * Get all vouchers with optional filtering
     */
    async findAll(userId: string, filter?: VoucherFilterDto) {
        const where: any = {
            router: {
                userId,
            },
        };

        if (filter?.routerId) {
            where.routerId = filter.routerId;
        }

        if (filter?.status) {
            where.status = filter.status;
        }

        if (filter?.planType) {
            where.planType = filter.planType;
        }

        const vouchers = await this.prisma.voucher.findMany({
            where,
            select: {
                id: true,
                username: true,
                password: true,
                planType: true,
                planName: true,
                duration: true,
                dataLimit: true,
                price: true,
                status: true,
                createdAt: true,
                activatedAt: true,
                expiresAt: true,
                soldAt: true,
                profile: {
                    select: {
                        name: true,
                    },
                },
                router: {
                    select: {
                        name: true,
                    },
                },
            },
            orderBy: { createdAt: 'desc' },
        });

        return vouchers.map(v => ({
            ...v,
            dataLimit: v.dataLimit ? Number(v.dataLimit) : null,
        }));
    }

    /**
     * Get a single voucher
     */
    async findOne(id: string, userId: string) {
        const voucher = await this.prisma.voucher.findFirst({
            where: {
                id,
                router: {
                    userId,
                },
            },
            include: {
                profile: true,
                router: {
                    select: {
                        id: true,
                        name: true,
                        ipAddress: true,
                    },
                },
                sessions: {
                    select: {
                        id: true,
                        startTime: true,
                        endTime: true,
                        bytesIn: true,
                        bytesOut: true,
                        isActive: true,
                    },
                },
            },
        });

        if (!voucher) {
            throw new NotFoundException('Voucher not found');
        }

        return {
            ...voucher,
            dataLimit: voucher.dataLimit ? Number(voucher.dataLimit) : null,
            sessions: voucher.sessions.map(s => ({
                ...s,
                bytesIn: Number(s.bytesIn),
                bytesOut: Number(s.bytesOut),
            })),
        };
    }

    /**
     * Activate a voucher (create RADIUS user)
     */
    async activate(id: string, userId: string) {
        const voucher = await this.prisma.voucher.findFirst({
            where: {
                id,
                router: {
                    userId,
                },
            },
            include: {
                router: true,
                profile: true,
            },
        });

        if (!voucher) {
            throw new NotFoundException('Voucher not found');
        }

        if (voucher.status !== VoucherStatus.UNUSED) {
            throw new BadRequestException('Voucher is already activated or expired');
        }

        // Create RADIUS user with profile group
        const groupName = `${voucher.profile.name}_${voucher.routerId.substring(0, 8)}`;
        await this.radiusService.createRadiusUser(voucher.username, voucher.password, groupName);

        // Set expiration for time-based plans
        if (voucher.planType === PlanType.TIME_BASED && voucher.duration) {
            const expiresAt = new Date(Date.now() + voucher.duration * 60 * 1000);
            await this.radiusService.setExpiration(voucher.username, expiresAt);
            await this.radiusService.setSessionTimeout(voucher.username, voucher.duration * 60);
        }

        // Update voucher status
        const expiration = this.calculateExpiration(voucher.planType, voucher.duration || undefined);

        const updatedVoucher = await this.prisma.voucher.update({
            where: { id },
            data: {
                status: VoucherStatus.ACTIVE,
                activatedAt: new Date(),
                expiresAt: expiration,
            },
        });

        // Log activity
        await this.prisma.activityLog.create({
            data: {
                userId,
                action: 'VOUCHER_ACTIVATED',
                details: JSON.stringify({
                    voucherId: id,
                    username: voucher.username,
                    routerId: voucher.routerId,
                }),
            },
        });

        this.logger.log(`Voucher ${id} activated via RADIUS for router ${voucher.routerId}`);

        return {
            ...updatedVoucher,
            dataLimit: updatedVoucher.dataLimit ? Number(updatedVoucher.dataLimit) : null,
        };
    }

    /**
     * Mark voucher as sold
     */
    async markAsSold(id: string, userId: string, customerName?: string, customerPhone?: string) {
        const voucher = await this.prisma.voucher.findFirst({
            where: {
                id,
                router: {
                    userId,
                },
            },
        });

        if (!voucher) {
            throw new NotFoundException('Voucher not found');
        }

        // Update voucher
        const updatedVoucher = await this.prisma.voucher.update({
            where: { id },
            data: {
                status: VoucherStatus.SOLD,
                soldAt: new Date(),
            },
        });

        // Create sale record
        await this.prisma.sale.create({
            data: {
                amount: voucher.price,
                customerName,
                customerPhone,
                voucherId: id,
                userId,
            },
        });

        // Log activity
        await this.prisma.activityLog.create({
            data: {
                userId,
                action: 'VOUCHER_SOLD',
                details: JSON.stringify({
                    voucherId: id,
                    amount: Number(voucher.price),
                    customerName,
                }),
            },
        });

        return {
            ...updatedVoucher,
            dataLimit: updatedVoucher.dataLimit ? Number(updatedVoucher.dataLimit) : null,
        };
    }

    /**
     * Delete a voucher
     */
    async remove(id: string, userId: string) {
        const voucher = await this.prisma.voucher.findFirst({
            where: {
                id,
                router: {
                    userId,
                },
            },
            include: {
                router: true,
            },
        });

        if (!voucher) {
            throw new NotFoundException('Voucher not found');
        }

        // If voucher is active, remove RADIUS user
        if (voucher.status === VoucherStatus.ACTIVE) {
            await this.radiusService.removeRadiusUser(voucher.username);
        }

        // Delete voucher
        await this.prisma.voucher.delete({
            where: { id },
        });

        // Log activity
        await this.prisma.activityLog.create({
            data: {
                userId,
                action: 'VOUCHER_DELETED',
                details: JSON.stringify({
                    voucherId: id,
                    username: voucher.username,
                }),
            },
        });

        return { message: 'Voucher deleted successfully' };
    }

    /**
     * Get voucher statistics
     */
    async getStatistics(userId: string, routerId?: string) {
        const where: any = {
            router: {
                userId,
            },
        };

        if (routerId) {
            where.routerId = routerId;
        }

        const [total, unused, active, expired, sold] = await Promise.all([
            this.prisma.voucher.count({ where }),
            this.prisma.voucher.count({ where: { ...where, status: VoucherStatus.UNUSED } }),
            this.prisma.voucher.count({ where: { ...where, status: VoucherStatus.ACTIVE } }),
            this.prisma.voucher.count({ where: { ...where, status: VoucherStatus.EXPIRED } }),
            this.prisma.voucher.count({ where: { ...where, status: VoucherStatus.SOLD } }),
        ]);

        const totalRevenue = await this.prisma.sale.aggregate({
            where: {
                userId,
                ...(routerId && {
                    voucher: {
                        routerId,
                    },
                }),
            },
            _sum: {
                amount: true,
            },
        });

        return {
            total,
            unused,
            active,
            expired,
            sold,
            totalRevenue: totalRevenue._sum.amount ? Number(totalRevenue._sum.amount) : 0,
        };
    }

    /**
     * Helper: Decrypt router password
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
}
