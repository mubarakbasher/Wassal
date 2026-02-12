import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class SubscriptionsService {
    constructor(private prisma: PrismaService) { }

    async getAvailablePlans() {
        return this.prisma.subscriptionPlan.findMany({
            orderBy: { price: 'asc' },
            select: {
                id: true,
                name: true,
                price: true,
                durationDays: true,
                description: true,
                maxRouters: true,
                maxHotspotUsers: true,
                allowReports: true,
                allowVouchers: true,
            },
        });
    }

    async getMySubscription(userId: string) {
        const subscription = await this.prisma.userSubscription.findUnique({
            where: { userId },
            include: {
                plan: {
                    select: {
                        id: true,
                        name: true,
                        price: true,
                        durationDays: true,
                        description: true,
                        maxRouters: true,
                        maxHotspotUsers: true,
                        allowReports: true,
                        allowVouchers: true,
                    },
                },
            },
        });

        if (!subscription) {
            return { status: 'NONE', subscription: null };
        }

        const isExpired = subscription.expiresAt < new Date();
        return {
            status: isExpired ? 'EXPIRED' : subscription.status,
            subscription: {
                id: subscription.id,
                planName: subscription.plan.name,
                planId: subscription.planId,
                startDate: subscription.startDate,
                expiresAt: subscription.expiresAt,
                plan: subscription.plan,
            },
        };
    }

    async requestSubscription(userId: string, planId: string) {
        // Create a pending payment for the subscription
        const plan = await this.prisma.subscriptionPlan.findUnique({
            where: { id: planId },
        });

        if (!plan) {
            throw new Error('Plan not found');
        }

        // Create payment record (admin will approve it)
        const payment = await this.prisma.payment.create({
            data: {
                userId,
                planId: plan.id,
                amount: plan.price,
                method: 'PENDING',
                status: 'PENDING',
                notes: `Subscription request for ${plan.name} plan`,
            },
        });

        return {
            message: 'Subscription request submitted. Please wait for admin approval.',
            payment: {
                id: payment.id,
                amount: payment.amount,
                planName: plan.name,
            },
        };
    }
}
