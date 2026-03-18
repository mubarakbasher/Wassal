import { Controller, Get, Post, Patch, Body, Query, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AdminSystemService } from './admin-system.service';
import { AdminJwtAuthGuard } from '../auth/guards/admin-jwt-auth.guard';
import { UpdateConfigDto, ChangePasswordDto, UpdateProfileDto } from './dto/admin-system.dto';

@ApiTags('Admin System')
@ApiBearerAuth('JWT')
@Controller('admin/system')
@UseGuards(AdminJwtAuthGuard)
export class AdminSystemController {
    constructor(private readonly systemService: AdminSystemService) { }

    @Get('audit-logs')
    @ApiOperation({ summary: 'Get audit logs' })
    getAuditLogs(@Query('page') page: string = '1') {
        return this.systemService.getAuditLogs(+page || 1);
    }

    @Get('config')
    @ApiOperation({ summary: 'Get system configuration' })
    getConfig() {
        return this.systemService.getSystemConfig();
    }

    @Post('config')
    @ApiOperation({ summary: 'Update system configuration' })
    updateConfig(@Body() body: UpdateConfigDto) {
        return this.systemService.updateSystemConfig(body.key, body.value);
    }

    @Get('stats')
    @ApiOperation({ summary: 'Get dashboard statistics' })
    getStats() {
        return this.systemService.getDashboardStats();
    }

    @Get('revenue-chart')
    @ApiOperation({ summary: 'Get revenue chart data' })
    getRevenueChart() {
        return this.systemService.getRevenueChart();
    }

    @Get('profile')
    @ApiOperation({ summary: 'Get admin profile' })
    getProfile(@Request() req: any) {
        return this.systemService.getAdminProfile(req.user.id);
    }

    @Patch('profile')
    @ApiOperation({ summary: 'Update admin profile' })
    updateProfile(@Request() req: any, @Body() body: UpdateProfileDto) {
        return this.systemService.updateAdminProfile(req.user.id, body);
    }

    @Patch('change-password')
    @ApiOperation({ summary: 'Change admin password' })
    changePassword(
        @Request() req: any,
        @Body() body: ChangePasswordDto,
    ) {
        return this.systemService.changeAdminPassword(req.user.id, body.currentPassword, body.newPassword);
    }
}
