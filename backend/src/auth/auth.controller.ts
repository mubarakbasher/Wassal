import { Controller, Post, Get, Body, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import { AuthService } from './auth.service';
import { RegisterDto, LoginDto, RefreshTokenDto, ForgotPasswordDto, ResetPasswordDto } from './dto/auth.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { CurrentUser } from './decorators/current-user.decorator';

@Controller('auth')
export class AuthController {
    constructor(private authService: AuthService) { }

    @Post('register')
    @Throttle({ short: { limit: 3, ttl: 60000 } }) // 3 registrations per minute
    async register(@Body() registerDto: RegisterDto) {
        return this.authService.register(registerDto);
    }

    @Post('login')
    @HttpCode(HttpStatus.OK)
    @Throttle({ short: { limit: 5, ttl: 60000 } }) // 5 login attempts per minute
    async login(@Body() loginDto: LoginDto) {
        return this.authService.login(loginDto);
    }

    @Post('refresh')
    @HttpCode(HttpStatus.OK)
    async refresh(@Body() refreshTokenDto: RefreshTokenDto) {
        return this.authService.refreshTokens(refreshTokenDto.refreshToken);
    }

    @Post('forgot-password')
    @HttpCode(HttpStatus.OK)
    @Throttle({ short: { limit: 3, ttl: 300000 } }) // 3 resets per 5 minutes
    async forgotPassword(@Body() dto: ForgotPasswordDto) {
        return this.authService.forgotPassword(dto.email);
    }

    @Post('reset-password')
    @HttpCode(HttpStatus.OK)
    @Throttle({ short: { limit: 5, ttl: 60000 } }) // 5 attempts per minute
    async resetPassword(@Body() dto: ResetPasswordDto) {
        return this.authService.resetPassword(dto.email, dto.code, dto.newPassword);
    }

    @Get('profile')
    @UseGuards(JwtAuthGuard)
    async getProfile(@CurrentUser() user: any) {
        return this.authService.getProfile(user.id);
    }
}
