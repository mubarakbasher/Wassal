import { Controller, Get, Post, Patch, Delete, Body, Param, Query, UseGuards } from '@nestjs/common';
import { AdminSubscriptionsService } from './admin-subscriptions.service';
import { AdminJwtAuthGuard } from '../auth/guards/admin-jwt-auth.guard';

@Controller('admin/subscriptions')
@UseGuards(AdminJwtAuthGuard)
export class AdminSubscriptionsController {
    constructor(private readonly subService: AdminSubscriptionsService) { }

    // --- Plans ---
    @Get('plans')
    getPlans() {
        return this.subService.findAllPlans();
    }

    @Post('plans')
    createPlan(@Body() data: any) {
        return this.subService.createPlan(data);
    }

    @Patch('plans/:id')
    updatePlan(@Param('id') id: string, @Body() data: any) {
        return this.subService.updatePlan(id, data);
    }

    @Delete('plans/:id')
    deletePlan(@Param('id') id: string) {
        return this.subService.deletePlan(id);
    }

    // --- User Subscriptions ---
    @Get()
    getSubscriptions(
        @Query('page') page: string = '1',
        @Query('status') status: string
    ) {
        return this.subService.findAllSubscriptions(+page, 10, status);
    }

    @Patch(':id/extend')
    extendSubscription(
        @Param('id') id: string,
        @Body('days') days: number
    ) {
        return this.subService.extendSubscription(id, days);
    }

    @Post('assign')
    assignSubscription(@Body() body: { userId: string, planId: string, durationDays?: number }) {
        return this.subService.assignSubscription(body.userId, body.planId, body.durationDays);
    }
    @Patch(':id/cancel')
    cancelSubscription(@Param('id') id: string) {
        return this.subService.cancelSubscription(id);
    }
}

