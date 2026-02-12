import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class AdminPaymentsService {
    constructor(private prisma: PrismaService) { }

    async findAll(page: number = 1, limit: number = 10, status?: string) {
        const skip = (page - 1) * limit;
        const where: any = {};
        if (status && status !== 'ALL') where.status = status;

        const [payments, total] = await Promise.all([
            this.prisma.payment.findMany({
                where,
                skip,
                take: limit,
                include: {
                    user: { select: { email: true, name: true } }
                },
                orderBy: { createdAt: 'desc' }
            }),
            this.prisma.payment.count({ where }),
        ]);

        return {
            data: payments,
            meta: { total, page, lastPage: Math.ceil(total / limit) }
        };
    }

    async reviewPayment(id: string, adminId: string, status: 'APPROVED' | 'REJECTED', notes?: string) {
        const payment = await this.prisma.payment.findUnique({ where: { id } });
        if (!payment) throw new NotFoundException('Payment not found');

        const updatedPayment = await this.prisma.payment.update({
            where: { id },
            data: {
                status,
                reviewedBy: adminId,
                reviewedAt: new Date(),
                notes: notes ? notes : undefined
            }
        });

        // Auto-activate subscription when payment is approved and has a linked plan
        if (status === 'APPROVED' && payment.planId) {
            const plan = await this.prisma.subscriptionPlan.findUnique({
                where: { id: payment.planId },
            });

            if (plan) {
                const expiresAt = new Date();
                expiresAt.setDate(expiresAt.getDate() + plan.durationDays);

                await this.prisma.userSubscription.upsert({
                    where: { userId: payment.userId },
                    update: {
                        planId: payment.planId,
                        status: 'ACTIVE',
                        startDate: new Date(),
                        expiresAt,
                    },
                    create: {
                        userId: payment.userId,
                        planId: payment.planId,
                        status: 'ACTIVE',
                        startDate: new Date(),
                        expiresAt,
                    },
                });
            }
        }

        return updatedPayment;
    }

    async exportPaymentsCsv(): Promise<string> {
        const payments = await this.prisma.payment.findMany({
            orderBy: { createdAt: 'desc' },
            include: { user: { select: { email: true, name: true } } },
        });

        const header = 'User,Email,Amount,Method,Status,Date,Notes\n';
        const rows = payments.map(p =>
            `"${p.user?.name || ''}","${p.user?.email || ''}","${p.amount}","${p.method}","${p.status}","${p.createdAt.toISOString()}","${p.notes || ''}"`
        ).join('\n');

        return header + rows;
    }
}
