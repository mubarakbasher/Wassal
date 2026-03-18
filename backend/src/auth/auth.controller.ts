import { Controller, Post, Get, Body, Query, Res, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import type { Response } from 'express';
import { AuthService } from './auth.service';
import { RegisterDto, LoginDto, RefreshTokenDto, ForgotPasswordDto, ResetPasswordDto, VerifyEmailDto, ResendVerificationDto } from './dto/auth.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { CurrentUser } from './decorators/current-user.decorator';

@ApiTags('Auth')
@Controller('auth')
export class AuthController {
    constructor(private authService: AuthService) { }

    private setTokenCookies(res: Response, accessToken: string, refreshToken: string) {
        const isProduction = process.env.NODE_ENV === 'production';

        res.cookie('access_token', accessToken, {
            httpOnly: true,
            secure: isProduction,
            sameSite: isProduction ? 'strict' : 'lax',
            maxAge: 24 * 60 * 60 * 1000, // 1 day (access token)
            path: '/',
        });

        res.cookie('refresh_token', refreshToken, {
            httpOnly: true,
            secure: isProduction,
            sameSite: isProduction ? 'strict' : 'lax',
            maxAge: 90 * 24 * 60 * 60 * 1000, // 90 days
            path: '/auth/refresh',
        });
    }

    @Post('register')
    @ApiOperation({ summary: 'Register a new user account' })
    @Throttle({ short: { limit: 3, ttl: 60000 } })
    async register(@Body() registerDto: RegisterDto, @Res({ passthrough: true }) res: Response) {
        const result = await this.authService.register(registerDto);
        this.setTokenCookies(res, result.accessToken, result.refreshToken);
        return result;
    }

    @Post('login')
    @ApiOperation({ summary: 'Login with email and password' })
    @HttpCode(HttpStatus.OK)
    @Throttle({ short: { limit: 5, ttl: 60000 } })
    async login(@Body() loginDto: LoginDto, @Res({ passthrough: true }) res: Response) {
        const result = await this.authService.login(loginDto);
        this.setTokenCookies(res, result.accessToken, result.refreshToken);
        return result;
    }

    @Post('refresh')
    @ApiOperation({ summary: 'Refresh access token using refresh token' })
    @HttpCode(HttpStatus.OK)
    async refresh(@Body() refreshTokenDto: RefreshTokenDto, @Res({ passthrough: true }) res: Response) {
        const result = await this.authService.refreshTokens(refreshTokenDto.refreshToken);
        this.setTokenCookies(res, result.accessToken, result.refreshToken);
        return result;
    }

    @Post('forgot-password')
    @ApiOperation({ summary: 'Request a password reset code via email' })
    @HttpCode(HttpStatus.OK)
    @Throttle({ short: { limit: 3, ttl: 300000 } })
    async forgotPassword(@Body() dto: ForgotPasswordDto) {
        return this.authService.forgotPassword(dto.email);
    }

    @Post('reset-password')
    @ApiOperation({ summary: 'Reset password using the emailed code' })
    @HttpCode(HttpStatus.OK)
    @Throttle({ short: { limit: 5, ttl: 60000 } })
    async resetPassword(@Body() dto: ResetPasswordDto) {
        return this.authService.resetPassword(dto.email, dto.code, dto.newPassword);
    }

    @Get('verify-email')
    @ApiOperation({ summary: 'Verify email address using token from email link' })
    async verifyEmail(@Query() dto: VerifyEmailDto) {
        return this.authService.verifyEmail(dto.token);
    }

    @Post('resend-verification')
    @ApiOperation({ summary: 'Resend email verification link' })
    @HttpCode(HttpStatus.OK)
    @Throttle({ short: { limit: 2, ttl: 300000 } })
    async resendVerification(@Body() dto: ResendVerificationDto) {
        return this.authService.resendVerification(dto.email);
    }

    @Get('profile')
    @ApiOperation({ summary: 'Get current user profile' })
    @ApiBearerAuth('JWT')
    @UseGuards(JwtAuthGuard)
    async getProfile(@CurrentUser() user: any) {
        return this.authService.getProfile(user.id);
    }

    @Post('logout')
    @ApiOperation({ summary: 'Revoke all refresh tokens (logout from all devices)' })
    @ApiBearerAuth('JWT')
    @HttpCode(HttpStatus.OK)
    @UseGuards(JwtAuthGuard)
    async logout(@CurrentUser() user: any) {
        await this.authService.revokeAllTokens(user.id);
        return { message: 'Logged out from all devices' };
    }
}
