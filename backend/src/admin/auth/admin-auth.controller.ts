import { Body, Controller, Post, Res, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation } from '@nestjs/swagger';
import type { Response } from 'express';
import { AdminAuthService } from './admin-auth.service';
import { AdminLoginDto } from './dto/admin-login.dto';

@ApiTags('Admin Auth')
@Controller('admin/auth')
export class AdminAuthController {
    constructor(private readonly authService: AdminAuthService) { }

    @Post('login')
    @ApiOperation({ summary: 'Admin login' })
    @HttpCode(HttpStatus.OK)
    async login(@Body() loginDto: AdminLoginDto, @Res({ passthrough: true }) res: Response) {
        const result = await this.authService.login(loginDto);

        const isProduction = process.env.NODE_ENV === 'production';

        res.cookie('admin_access_token', result.access_token, {
            httpOnly: true,
            secure: isProduction,
            sameSite: isProduction ? 'strict' : 'lax',
            maxAge: 90 * 24 * 60 * 60 * 1000, // 90 days
            path: '/',
        });

        return result;
    }

    @Post('logout')
    @ApiOperation({ summary: 'Admin logout (clear cookie)' })
    @HttpCode(HttpStatus.OK)
    async logout(@Res({ passthrough: true }) res: Response) {
        res.clearCookie('admin_access_token', { path: '/' });
        return { message: 'Logged out successfully' };
    }
}
