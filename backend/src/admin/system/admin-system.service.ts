import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AdminSystemService {
    constructor(private prisma: PrismaService) { }

    // --- Audit Logs ---
    async getAuditLogs(page: number = 1, limit: number = 20) {
        const skip = (page - 1) * limit;
        const [logs, total] = await Promise.all([
            this.prisma.adminAuditLog.findMany({
                skip,
                take: limit,
                include: { admin: { select: { email: true, name: true } } },
                orderBy: { createdAt: 'desc' }
            }),
            this.prisma.adminAuditLog.count()
        ]);

        return {
            data: logs,
            meta: { total, page, lastPage: Math.ceil(total / limit) }
        };
    }

    // --- System Config ---
    async getSystemConfig() {
        return this.prisma.systemConfig.findMany();
    }

    async updateSystemConfig(key: string, value: string) {
        return this.prisma.systemConfig.upsert({
            where: { key },
            update: { value },
            create: { key, value }
        });
    }

    // --- Dashboard Stats ---
    async getDashboardStats() {
        const [users, revenue, activeSubs] = await Promise.all([
            this.prisma.user.count(),
            this.prisma.payment.aggregate({
                _sum: { amount: true },
                where: { status: 'APPROVED' }
            }),
            this.prisma.userSubscription.count({ where: { status: 'ACTIVE' } })
        ]);

        return {
            totalUsers: users,
            totalRevenue: revenue._sum.amount || 0,
            activeSubscriptions: activeSubs,
        };
    }

    // --- Revenue Chart (last 6 months) ---
    async getRevenueChart() {
        const months: { month: string; revenue: number; count: number }[] = [];

        for (let i = 5; i >= 0; i--) {
            const date = new Date();
            date.setMonth(date.getMonth() - i);
            const startOfMonth = new Date(date.getFullYear(), date.getMonth(), 1);
            const endOfMonth = new Date(date.getFullYear(), date.getMonth() + 1, 0, 23, 59, 59);

            const result = await this.prisma.payment.aggregate({
                _sum: { amount: true },
                _count: { id: true },
                where: {
                    status: 'APPROVED',
                    createdAt: {
                        gte: startOfMonth,
                        lte: endOfMonth,
                    },
                },
            });

            const monthLabel = startOfMonth.toLocaleString('en', { month: 'short', year: '2-digit' });
            months.push({
                month: monthLabel,
                revenue: Number(result._sum.amount || 0),
                count: result._count.id,
            });
        }

        return months;
    }

    // --- Admin Change Password ---
    async changeAdminPassword(adminId: string, currentPassword: string, newPassword: string) {
        const admin = await this.prisma.admin.findUnique({ where: { id: adminId } });
        if (!admin) {
            throw new UnauthorizedException('Admin not found');
        }

        const isValid = await bcrypt.compare(currentPassword, admin.password);
        if (!isValid) {
            throw new UnauthorizedException('Current password is incorrect');
        }

        const hashedPassword = await bcrypt.hash(newPassword, 10);
        await this.prisma.admin.update({
            where: { id: adminId },
            data: { password: hashedPassword },
        });

        return { message: 'Password updated successfully' };
    }

    // --- Admin Profile ---
    async getAdminProfile(adminId: string) {
        return this.prisma.admin.findUnique({
            where: { id: adminId },
            select: {
                id: true,
                email: true,
                name: true,
                role: true,
                createdAt: true,
            },
        });
    }

    async updateAdminProfile(adminId: string, data: { name?: string; email?: string }) {
        return this.prisma.admin.update({
            where: { id: adminId },
            data,
            select: {
                id: true,
                email: true,
                name: true,
                role: true,
                createdAt: true,
            },
        });
    }
}
