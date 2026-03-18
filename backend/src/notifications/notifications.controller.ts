import { Controller, Post, Delete, Body, UseGuards, Req } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { NotificationsService } from './notifications.service';
import { RegisterTokenDto } from './dto/register-token.dto';

@ApiTags('Notifications')
@ApiBearerAuth('JWT')
@Controller('notifications')
@UseGuards(JwtAuthGuard)
export class NotificationsController {
    constructor(private readonly notificationsService: NotificationsService) { }

    @Post('register-token')
    @ApiOperation({ summary: 'Register a push notification device token' })
    async registerToken(@Req() req, @Body() dto: RegisterTokenDto) {
        await this.notificationsService.registerToken(req.user.id, dto.token, dto.platform);
        return { success: true, message: 'Device token registered' };
    }

    @Delete('remove-token')
    @ApiOperation({ summary: 'Remove a push notification device token' })
    async removeToken(@Req() req, @Body('token') token: string) {
        await this.notificationsService.removeToken(token, req.user.id);
        return { success: true, message: 'Device token removed' };
    }
}
