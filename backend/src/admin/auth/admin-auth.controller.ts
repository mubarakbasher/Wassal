import { Body, Controller, Post, HttpCode, HttpStatus } from '@nestjs/common';
import { AdminAuthService } from './admin-auth.service';
import { AdminLoginDto } from './dto/admin-login.dto';

@Controller('admin/auth')
export class AdminAuthController {
    constructor(private readonly authService: AdminAuthService) { }

    @Post('login')
    @HttpCode(HttpStatus.OK)
    async login(@Body() loginDto: AdminLoginDto) {
        return this.authService.login(loginDto);
    }
}
