import { Controller, Get, Post, Body, UseGuards } from '@nestjs/common';
import { SubscriptionsService } from './subscriptions.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@Controller('subscriptions')
export class SubscriptionsController {
    constructor(private readonly subscriptionsService: SubscriptionsService) { }

    @Get('plans')
    getPlans() {
        return this.subscriptionsService.getAvailablePlans();
    }

    @Get('my')
    @UseGuards(JwtAuthGuard)
    getMySubscription(@CurrentUser() user: any) {
        return this.subscriptionsService.getMySubscription(user.id);
    }

    @Post('request')
    @UseGuards(JwtAuthGuard)
    requestSubscription(
        @CurrentUser() user: any,
        @Body() body: { planId: string },
    ) {
        return this.subscriptionsService.requestSubscription(user.id, body.planId);
    }
}
