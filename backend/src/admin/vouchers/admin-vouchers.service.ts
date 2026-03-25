import { Injectable, NotFoundException, BadRequestException, Logger } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { RadiusService } from '../../radius/radius.service';
import { VoucherStatus } from '@prisma/client';

@Injectable()
export class AdminVouchersService {
    private readonly logger = new Logger(AdminVouchersService.name);

    constructor(
        private prisma: PrismaService,
        private radiusService: RadiusService,
    ) { }

    async findAll(page: number = 1, limit: number = 20, status?: string, routerId?: string, search?: string) {
        const skip = (page - 1) * limit;
        const where: any = {};

        if (routerId) where.routerId = routerId;
        if (status) where.status = status;
        if (search) {
            where.OR = [
                { username: { contains: search, mode: 'insensitive' } },
                { planName: { contains: search, mode: 'insensitive' } },
            ];
        }

        const voucherSelect = {
            id: true,
            username: true,
            password: true,
            planType: true,
            countType: true,
            planName: true,
            duration: true,
            dataLimit: true,
            price: true,
            status: true,
            createdAt: true,
            activatedAt: true,
            expiresAt: true,
            soldAt: true,
            profile: { select: { name: true } },
            router: { select: { id: true, name: true, user: { select: { name: true, email: true } } } },
        };

        const [vouchers, total] = await Promise.all([
            this.prisma.voucher.findMany({
                where,
                select: voucherSelect,
                orderBy: { createdAt: 'desc' },
                skip,
                take: limit,
            }),
            this.prisma.voucher.count({ where }),
        ]);

        return {
            data: vouchers.map(v => ({
                ...v,
                dataLimit: v.dataLimit ? Number(v.dataLimit) : null,
            })),
            meta: {
                total,
                page,
                lastPage: Math.ceil(total / limit),
            },
        };
    }

    /** Admin creates vouchers — delegates to the existing VouchersService logic via Prisma */
    async create(data: any) {
        const {
            routerId,
            mikrotikProfile,
            planType,
            countType = 'WALL_CLOCK',
            authType = 'USERNAME_ONLY',
            planName,
            duration,
            dataLimit,
            price,
            quantity,
        } = data;

        // Verify router exists
        const router = await this.prisma.router.findUnique({ where: { id: routerId } });
        if (!router) {
            throw new NotFoundException('Router not found');
        }

        let profileId: string | null = null;
        let groupName: string;

        if (countType === 'WALL_CLOCK') {
            // WALL_CLOCK: requires a MikroTik profile
            let profile = await this.prisma.hotspotProfile.findFirst({
                where: { routerId, name: mikrotikProfile || 'default' },
            });

            if (!profile && mikrotikProfile) {
                profile = await this.prisma.hotspotProfile.create({
                    data: {
                        name: mikrotikProfile,
                        routerId,
                        sharedUsers: 1,
                    },
                });
            }

            if (!profile) {
                throw new BadRequestException('A MikroTik profile is required for Wall Clock vouchers.');
            }

            profileId = profile.id;
            groupName = `${profile.name}_${routerId.substring(0, 8)}`;
            await this.radiusService.upsertGroup(groupName, {
                sharedUsers: profile.sharedUsers,
            });
        } else {
            // ONLINE_ONLY: no profile needed, use RADIUS for time/data tracking
            groupName = `radius_${routerId.substring(0, 8)}`;
            await this.radiusService.upsertGroup(groupName, {
                sharedUsers: 1,
            });
        }

        const vouchers: any[] = [];
        const count = quantity || 1;

        const adminNasIp = router.vpnIp || router.ipAddress;
        for (let i = 0; i < count; i++) {
            const username = this.generateRandomString(8);
            let password = '';

            if (authType === 'USERNAME_ONLY') {
                password = '';
                await this.radiusService.createRadiusUserPasswordless(username, groupName, adminNasIp);
            } else {
                password = authType === 'USER_SAME_PASS' ? username : this.generateRandomString(8);
                await this.radiusService.createRadiusUser(username, password, groupName, adminNasIp);
            }

            // Only set Max-All-Session for ONLINE_ONLY count type
            if (planType === 'TIME_BASED' && duration && countType === 'ONLINE_ONLY') {
                const seconds = duration * 60;
                await this.radiusService.setMaxAllSession(username, seconds);
                await this.radiusService.setSessionTimeout(username, seconds);
            }

            if (dataLimit) {
                await this.radiusService.setUserReplyAttribute(
                    username, 'Mikrotik-Total-Limit', dataLimit.toString(),
                );
            }

            const voucher = await this.prisma.voucher.create({
                data: {
                    username,
                    password,
                    planType,
                    countType,
                    planName,
                    duration,
                    dataLimit: dataLimit ? BigInt(dataLimit) : null,
                    price,
                    status: VoucherStatus.UNUSED,
                    profileId: profileId || null,
                    routerId,
                },
                select: {
                    id: true,
                    username: true,
                    password: true,
                    planType: true,
                    countType: true,
                    planName: true,
                    duration: true,
                    dataLimit: true,
                    price: true,
                    status: true,
                    createdAt: true,
                },
            });

            vouchers.push({
                ...voucher,
                dataLimit: voucher.dataLimit ? Number(voucher.dataLimit) : null,
            });
        }

        return vouchers;
    }

    /** Admin deletes a voucher (no user-scope filter) */
    async remove(id: string) {
        const voucher = await this.prisma.voucher.findUnique({ where: { id } });
        if (!voucher) {
            throw new NotFoundException('Voucher not found');
        }

        // Remove RADIUS user if active or unused
        if (voucher.status === VoucherStatus.ACTIVE || voucher.status === VoucherStatus.UNUSED) {
            await this.radiusService.removeRadiusUser(voucher.username);
        }

        await this.prisma.voucher.delete({ where: { id } });

        this.logger.log(`Voucher ${voucher.username} deleted by admin`);
        return { message: 'Voucher deleted successfully' };
    }

    private generateRandomString(length: number): string {
        const chars = '0123456789';
        let result = '';
        const randomBytes = require('crypto').randomBytes(length);
        for (let i = 0; i < length; i++) {
            result += chars[randomBytes[i] % chars.length];
        }
        return result;
    }
}
