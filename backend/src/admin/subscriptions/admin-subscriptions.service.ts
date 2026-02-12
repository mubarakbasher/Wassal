import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class AdminSubscriptionsService {
    constructor(private prisma: PrismaService) { }

    // --- Plans ---
    async findAllPlans() {
        return this.prisma.subscriptionPlan.findMany();
    }

    async createPlan(data: any) {
        return this.prisma.subscriptionPlan.create({ data });
    }

    async updatePlan(id: string, data: any) {
        return this.prisma.subscriptionPlan.update({ where: { id }, data });
    }

    async deletePlan(id: string) {
        // Check if used
        const count = await this.prisma.userSubscription.count({ where: { planId: id } });
        if (count > 0) throw new BadRequestException('Cannot delete plan with active subscriptions');
        return this.prisma.subscriptionPlan.delete({ where: { id } });
    }

    // --- User Subscriptions ---
    async findAllSubscriptions(page: number = 1, limit: number = 10, status?: string) {
        const skip = (page - 1) * limit;
        const where: any = {};
        if (status && status !== 'ALL') where.status = status;

        const [subs, total] = await Promise.all([
            this.prisma.userSubscription.findMany({
                where,
                skip,
                take: limit,
                include: {
                    user: { select: { email: true, name: true } },
                    plan: true,
                },
                orderBy: { createdAt: 'desc' }
            }),
            this.prisma.userSubscription.count({ where }),
        ]);

        return {
            data: subs,
            meta: { total, page, lastPage: Math.ceil(total / limit) }
        };
    }

    async extendSubscription(id: string, days: number) {
        const sub = await this.prisma.userSubscription.findUnique({ where: { id } });
        if (!sub) throw new NotFoundException('Subscription not found');

        const newDate = new Date(sub.expiresAt);
        newDate.setDate(newDate.getDate() + days);

        return this.prisma.userSubscription.update({
            where: { id },
            data: { expiresAt: newDate, status: 'ACTIVE' }
        });
    }

    async assignSubscription(userId: string, planId: string, durationDays?: number) {
        const plan = await this.prisma.subscriptionPlan.findUnique({ where: { id: planId } });
        if (!plan) throw new NotFoundException('Plan not found');

        const days = durationDays || plan.durationDays;
        const expiresAt = new Date();
        expiresAt.setDate(expiresAt.getDate() + days);

        // Since userId is unique in UserSubscription, we use upsert
        return this.prisma.userSubscription.upsert({
            where: { userId },
            update: {
                planId,
                status: 'ACTIVE',
                startDate: new Date(),
                expiresAt,
            },
            create: {
                userId,
                planId,
                status: 'ACTIVE',
                startDate: new Date(),
                expiresAt,
            }
        });
    }
    async cancelSubscription(id: string) {
        return this.prisma.userSubscription.update({
            where: { id },
            data: { status: 'CANCELLED' }
        });
    }
}


