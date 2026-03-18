import { Controller, Get, Post, Patch, Delete, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AdminSubscriptionsService } from './admin-subscriptions.service';
import { AdminJwtAuthGuard } from '../auth/guards/admin-jwt-auth.guard';
import { CreatePlanDto, UpdatePlanDto, AssignSubscriptionDto, ExtendSubscriptionDto } from './dto/admin-subscription.dto';

@ApiTags('Admin Subscriptions')
@ApiBearerAuth('JWT')
@Controller('admin/subscriptions')
@UseGuards(AdminJwtAuthGuard)
export class AdminSubscriptionsController {
    constructor(private readonly subService: AdminSubscriptionsService) { }

    @Get('plans')
    @ApiOperation({ summary: 'List all subscription plans' })
    getPlans() {
        return this.subService.findAllPlans();
    }

    @Post('plans')
    @ApiOperation({ summary: 'Create a subscription plan' })
    createPlan(@Body() data: CreatePlanDto) {
        return this.subService.createPlan(data);
    }

    @Patch('plans/:id')
    @ApiOperation({ summary: 'Update a subscription plan' })
    updatePlan(@Param('id') id: string, @Body() data: UpdatePlanDto) {
        return this.subService.updatePlan(id, data);
    }

    @Delete('plans/:id')
    @ApiOperation({ summary: 'Delete a subscription plan' })
    deletePlan(@Param('id') id: string) {
        return this.subService.deletePlan(id);
    }

    @Get()
    @ApiOperation({ summary: 'List all user subscriptions' })
    getSubscriptions(
        @Query('page') page: string = '1',
        @Query('status') status: string
    ) {
        return this.subService.findAllSubscriptions(+page, 10, status);
    }

    @Patch(':id/extend')
    @ApiOperation({ summary: 'Extend a subscription' })
    extendSubscription(
        @Param('id') id: string,
        @Body() body: ExtendSubscriptionDto
    ) {
        return this.subService.extendSubscription(id, body.days);
    }

    @Post('assign')
    @ApiOperation({ summary: 'Assign a subscription to a user' })
    assignSubscription(@Body() body: AssignSubscriptionDto) {
        return this.subService.assignSubscription(body.userId, body.planId, body.durationDays);
    }

    @Patch(':id/cancel')
    @ApiOperation({ summary: 'Cancel a subscription' })
    cancelSubscription(@Param('id') id: string) {
        return this.subService.cancelSubscription(id);
    }
}

