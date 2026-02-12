import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { Session } from '@prisma/client';

export interface SessionStatistics {
    totalSessions: number;
    activeSessions: number;
    totalBandwidthIn: number;
    totalBandwidthOut: number;
    averageUptime: number;
}

@Injectable()
export class SessionsService {
    constructor(private prisma: PrismaService) { }

    async findAll(isActive?: boolean): Promise<Session[]> {
        const where = isActive !== undefined ? { isActive } : {};

        return this.prisma.session.findMany({
            where,
            include: {
                router: {
                    select: {
                        id: true,
                        name: true,
                        ipAddress: true,
                    },
                },
                voucher: {
                    select: {
                        id: true,
                        username: true,
                        planName: true,
                    },
                },
            },
            orderBy: {
                startTime: 'desc',
            },
        });
    }

    async findByRouter(routerId: string, isActive?: boolean): Promise<Session[]> {
        const where: any = { routerId };
        if (isActive !== undefined) {
            where.isActive = isActive;
        }

        return this.prisma.session.findMany({
            where,
            include: {
                router: {
                    select: {
                        id: true,
                        name: true,
                        ipAddress: true,
                    },
                },
                voucher: {
                    select: {
                        id: true,
                        username: true,
                        planName: true,
                    },
                },
            },
            orderBy: {
                startTime: 'desc',
            },
        });
    }

    async findOne(id: string): Promise<Session> {
        const session = await this.prisma.session.findUnique({
            where: { id },
            include: {
                router: {
                    select: {
                        id: true,
                        name: true,
                        ipAddress: true,
                    },
                },
                voucher: {
                    select: {
                        id: true,
                        username: true,
                        planName: true,
                    },
                },
            },
        });

        if (!session) {
            throw new NotFoundException(`Session with ID ${id} not found`);
        }

        return session;
    }

    async getStatistics(routerId?: string): Promise<SessionStatistics> {
        const where = routerId ? { routerId } : {};

        const [totalSessions, activeSessions, aggregations] = await Promise.all([
            this.prisma.session.count({ where }),
            this.prisma.session.count({ where: { ...where, isActive: true } }),
            this.prisma.session.aggregate({
                where,
                _sum: {
                    bytesIn: true,
                    bytesOut: true,
                    uptime: true,
                },
                _count: {
                    id: true,
                },
            }),
        ]);

        const totalBandwidthIn = Number(aggregations._sum.bytesIn || 0);
        const totalBandwidthOut = Number(aggregations._sum.bytesOut || 0);
        const totalUptime = aggregations._sum.uptime || 0;
        const count = aggregations._count.id || 1;

        return {
            totalSessions,
            activeSessions,
            totalBandwidthIn,
            totalBandwidthOut,
            averageUptime: Math.floor(totalUptime / count),
        };
    }

    async terminateSession(id: string): Promise<Session> {
        const session = await this.findOne(id);

        // Update session to inactive
        return this.prisma.session.update({
            where: { id },
            data: {
                isActive: false,
                endTime: new Date(),
            },
            include: {
                router: {
                    select: {
                        id: true,
                        name: true,
                        ipAddress: true,
                    },
                },
            },
        });
    }

    async createSession(data: {
        username: string;
        routerId: string;
        voucherId?: string;
        ipAddress?: string;
        macAddress?: string;
    }): Promise<Session> {
        return this.prisma.session.create({
            data: {
                username: data.username,
                routerId: data.routerId,
                voucherId: data.voucherId,
                ipAddress: data.ipAddress,
                macAddress: data.macAddress,
                isActive: true,
            },
            include: {
                router: {
                    select: {
                        id: true,
                        name: true,
                        ipAddress: true,
                    },
                },
            },
        });
    }

    async updateSessionStats(
        id: string,
        bytesIn: number,
        bytesOut: number,
        uptime: number,
    ): Promise<Session> {
        return this.prisma.session.update({
            where: { id },
            data: {
                bytesIn: BigInt(bytesIn),
                bytesOut: BigInt(bytesOut),
                uptime,
            },
        });
    }
}
