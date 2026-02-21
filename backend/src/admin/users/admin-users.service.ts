import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AdminUsersService {
    constructor(private prisma: PrismaService) { }

    async createUser(data: any) {
        const { email, password, name, role, networkName } = data;

        const existing = await this.prisma.user.findUnique({ where: { email } });
        if (existing) throw new ConflictException('User with this email already exists');

        const hashedPassword = await bcrypt.hash(password, 10);

        return this.prisma.user.create({
            data: {
                email,
                password: hashedPassword,
                name,
                networkName,
                role: role || 'OPERATOR',
            }
        });
    }

    async findAll(page: number = 1, limit: number = 10, search?: string) {
        const skip = (page - 1) * limit;

        const where: any = {};
        if (search) {
            where.OR = [
                { email: { contains: search, mode: 'insensitive' } },
                { name: { contains: search, mode: 'insensitive' } },
            ];
        }

        const [users, total] = await Promise.all([
            this.prisma.user.findMany({
                where,
                skip,
                take: limit,
                orderBy: { createdAt: 'desc' },
                include: {
                    routers: { select: { id: true } },
                    _count: { select: { routers: true } },
                    subscription: {
                        select: {
                            status: true,
                            expiresAt: true,
                            plan: { select: { name: true } },
                        },
                    },
                }
            }),
            this.prisma.user.count({ where }),
        ]);

        return {
            data: users,
            meta: {
                total,
                page,
                lastPage: Math.ceil(total / limit),
            }
        };
    }

    async findOne(id: string) {
        const user = await this.prisma.user.findUnique({
            where: { id },
            include: {
                routers: true,
                payments: true,
                subscription: { include: { plan: true } },
            }
        });

        if (!user) throw new NotFoundException('User not found');

        // Enrich routers with RADIUS NAS connection status
        const routersWithRadius = await Promise.all(
            user.routers.map(async (router) => {
                const nasEntry = await this.prisma.nas.findFirst({
                    where: { nasname: router.ipAddress },
                });
                return {
                    ...router,
                    radiusConnected: !!nasEntry,
                    radiusNasId: nasEntry?.id || null,
                };
            }),
        );

        return {
            ...user,
            routers: routersWithRadius,
        };
    }

    async updateUserStatus(id: string, isActive: boolean) {
        return this.prisma.user.update({
            where: { id },
            data: { isActive },
        });
    }
    async deleteRouter(routerId: string) {
        return this.prisma.router.delete({
            where: { id: routerId }
        });
    }

    async exportUsersCsv(): Promise<string> {
        const users = await this.prisma.user.findMany({
            orderBy: { createdAt: 'desc' },
            include: { _count: { select: { routers: true } } },
        });

        const header = 'Name,Email,Role,Status,Routers,Joined\n';
        const rows = users.map(u =>
            `"${u.name || ''}","${u.email}","${u.role}","${u.isActive ? 'Active' : 'Banned'}","${u._count.routers}","${u.createdAt.toISOString()}"`
        ).join('\n');

        return header + rows;
    }
}

