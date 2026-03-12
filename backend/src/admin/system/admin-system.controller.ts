import { Controller, Get, Post, Patch, Body, Query, UseGuards, Request } from '@nestjs/common';
import { AdminSystemService } from './admin-system.service';
import { AdminJwtAuthGuard } from '../auth/guards/admin-jwt-auth.guard';
import { UpdateConfigDto, ChangePasswordDto, UpdateProfileDto } from './dto/admin-system.dto';

@Controller('admin/system')
@UseGuards(AdminJwtAuthGuard)
export class AdminSystemController {
    constructor(private readonly systemService: AdminSystemService) { }

    @Get('audit-logs')
    getAuditLogs(@Query('page') page: string = '1') {
        return this.systemService.getAuditLogs(+page || 1);
    }

    @Get('config')
    getConfig() {
        return this.systemService.getSystemConfig();
    }

    @Post('config')
    updateConfig(@Body() body: UpdateConfigDto) {
        return this.systemService.updateSystemConfig(body.key, body.value);
    }

    @Get('stats')
    getStats() {
        return this.systemService.getDashboardStats();
    }

    @Get('revenue-chart')
    getRevenueChart() {
        return this.systemService.getRevenueChart();
    }

    @Get('profile')
    getProfile(@Request() req: any) {
        return this.systemService.getAdminProfile(req.user.id);
    }

    @Patch('profile')
    updateProfile(@Request() req: any, @Body() body: UpdateProfileDto) {
        return this.systemService.updateAdminProfile(req.user.id, body);
    }

    @Patch('change-password')
    changePassword(
        @Request() req: any,
        @Body() body: ChangePasswordDto,
    ) {
        return this.systemService.changeAdminPassword(req.user.id, body.currentPassword, body.newPassword);
    }
}
