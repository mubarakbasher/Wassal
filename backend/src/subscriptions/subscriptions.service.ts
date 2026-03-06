import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
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
        const plan = await this.prisma.subscriptionPlan.findUnique({
            where: { id: planId },
        });

        if (!plan) {
            throw new NotFoundException('Plan not found');
        }

        const payment = await this.prisma.payment.create({
            data: {
                userId,
                planId: plan.id,
                amount: plan.price,
                method: 'BANK_TRANSFER',
                status: 'PENDING',
                currency: 'SDG',
                notes: `Subscription request for ${plan.name} plan`,
            },
        });

        const bankInfo = await this.getBankInfo();

        return {
            message: 'Subscription request created. Please transfer the amount and upload proof.',
            payment: {
                id: payment.id,
                amount: payment.amount,
                planName: plan.name,
            },
            bankInfo,
        };
    }

    async getMyPayments(userId: string) {
        const payments = await this.prisma.payment.findMany({
            where: { userId },
            include: {
                plan: {
                    select: { name: true, durationDays: true },
                },
            },
            orderBy: { createdAt: 'desc' },
        });

        return payments.map((p) => ({
            id: p.id,
            amount: p.amount,
            currency: p.currency,
            method: p.method,
            status: p.status,
            proofUrl: p.proofUrl,
            notes: p.notes,
            planName: p.plan?.name ?? 'Unknown',
            planDays: p.plan?.durationDays ?? 0,
            reviewedAt: p.reviewedAt,
            createdAt: p.createdAt,
        }));
    }

    async uploadProof(userId: string, paymentId: string, proofUrl: string) {
        const payment = await this.prisma.payment.findUnique({
            where: { id: paymentId },
        });

        if (!payment) {
            throw new NotFoundException('Payment not found');
        }

        if (payment.userId !== userId) {
            throw new ForbiddenException('You do not own this payment');
        }

        if (payment.status !== 'PENDING') {
            throw new ForbiddenException('Proof can only be uploaded for pending payments');
        }

        return this.prisma.payment.update({
            where: { id: paymentId },
            data: {
                proofUrl,
                method: 'BANK_TRANSFER',
            },
            select: {
                id: true,
                proofUrl: true,
                status: true,
            },
        });
    }

    async getBankInfo() {
        const keys = ['bank_name', 'bank_account_name', 'bank_account_number'];
        const configs = await this.prisma.systemConfig.findMany({
            where: { key: { in: keys } },
        });

        const configMap: Record<string, string> = {};
        for (const c of configs) {
            configMap[c.key] = c.value;
        }

        return {
            bankName: configMap['bank_name'] ?? 'Bankak',
            accountName: configMap['bank_account_name'] ?? '',
            accountNumber: configMap['bank_account_number'] ?? '',
        };
    }
}
