import { Controller, Post, Delete, Body, UseGuards, Req } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { NotificationsService } from './notifications.service';
import { RegisterTokenDto } from './dto/register-token.dto';

@Controller('notifications')
@UseGuards(JwtAuthGuard)
export class NotificationsController {
    constructor(private readonly notificationsService: NotificationsService) { }

    @Post('register-token')
    async registerToken(@Req() req, @Body() dto: RegisterTokenDto) {
        await this.notificationsService.registerToken(req.user.id, dto.token, dto.platform);
        return { success: true, message: 'Device token registered' };
    }

    @Delete('remove-token')
    async removeToken(@Body('token') token: string) {
        await this.notificationsService.removeToken(token);
        return { success: true, message: 'Device token removed' };
    }
}
