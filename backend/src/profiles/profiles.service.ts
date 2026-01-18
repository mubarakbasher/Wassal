import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateProfileDto, UpdateProfileDto } from './dto/profile.dto';

@Injectable()
export class ProfilesService {
    private readonly logger = new Logger(ProfilesService.name);

    constructor(private prisma: PrismaService) { }

    async create(userId: string, createProfileDto: CreateProfileDto) {
        const { routerId, name, sharedUsers, rateLimit, sessionTimeout, idleTimeout } = createProfileDto;

        // Verify router exists and belongs to user
        const router = await this.prisma.router.findFirst({
            where: { id: routerId, userId },
        });

        if (!router) {
            throw new NotFoundException('Router not found');
        }

        const profile = await this.prisma.hotspotProfile.create({
            data: {
                name,
                sharedUsers: sharedUsers || 1,
                rateLimit,
                sessionTimeout,
                idleTimeout,
                routerId,
            },
        });

        // Log activity
        await this.prisma.activityLog.create({
            data: {
                userId,
                action: 'PROFILE_CREATED',
                details: JSON.stringify({ profileId: profile.id, name: profile.name, routerId }),
            },
        });

        this.logger.log(`Profile ${profile.name} created for router ${routerId} by user ${userId}`);

        return profile;
    }

    async findAll(userId: string, routerId?: string) {
        const where: any = {
            router: {
                userId,
            },
        };

        if (routerId) {
            where.routerId = routerId;
        }

        return this.prisma.hotspotProfile.findMany({
            where,
            include: {
                router: {
                    select: {
                        id: true,
                        name: true,
                    },
                },
                _count: {
                    select: {
                        vouchers: true,
                    },
                },
            },
            orderBy: { createdAt: 'desc' },
        });
    }

    async findOne(id: string, userId: string) {
        const profile = await this.prisma.hotspotProfile.findFirst({
            where: {
                id,
                router: {
                    userId,
                },
            },
            include: {
                router: {
                    select: {
                        id: true,
                        name: true,
                    },
                },
                _count: {
                    select: {
                        vouchers: true,
                    },
                },
            },
        });

        if (!profile) {
            throw new NotFoundException('Profile not found');
        }

        return profile;
    }

    async update(id: string, userId: string, updateProfileDto: UpdateProfileDto) {
        // Verify profile exists and belongs to user
        const existingProfile = await this.prisma.hotspotProfile.findFirst({
            where: {
                id,
                router: {
                    userId,
                },
            },
        });

        if (!existingProfile) {
            throw new NotFoundException('Profile not found');
        }

        const profile = await this.prisma.hotspotProfile.update({
            where: { id },
            data: updateProfileDto,
        });

        // Log activity
        await this.prisma.activityLog.create({
            data: {
                userId,
                action: 'PROFILE_UPDATED',
                details: JSON.stringify({ profileId: id, name: profile.name }),
            },
        });

        return profile;
    }

    async remove(id: string, userId: string) {
        // Verify profile exists and belongs to user
        const profile = await this.prisma.hotspotProfile.findFirst({
            where: {
                id,
                router: {
                    userId,
                },
            },
        });

        if (!profile) {
            throw new NotFoundException('Profile not found');
        }

        // Delete profile
        await this.prisma.hotspotProfile.delete({
            where: { id },
        });

        // Log activity
        await this.prisma.activityLog.create({
            data: {
                userId,
                action: 'PROFILE_DELETED',
                details: JSON.stringify({ profileId: id, name: profile.name }),
            },
        });

        return { message: 'Profile deleted successfully' };
    }
}
