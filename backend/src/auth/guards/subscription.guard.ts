import { Injectable, CanActivate, ExecutionContext, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class SubscriptionGuard implements CanActivate {
    constructor(private prisma: PrismaService) { }

    async canActivate(context: ExecutionContext): Promise<boolean> {
        const request = context.switchToHttp().getRequest();
        const user = request.user;

        if (!user || !user.id) {
            throw new ForbiddenException('Authentication required');
        }

        const subscription = await this.prisma.userSubscription.findUnique({
            where: { userId: user.id },
        });

        if (!subscription) {
            throw new ForbiddenException('Active subscription required. Please subscribe to a plan.');
        }

        if (subscription.status !== 'ACTIVE') {
            throw new ForbiddenException('Your subscription is not active. Please renew your plan.');
        }

        if (subscription.expiresAt < new Date()) {
            throw new ForbiddenException('Your subscription has expired. Please renew your plan.');
        }

        return true;
    }
}
