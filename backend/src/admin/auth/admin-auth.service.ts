import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../../prisma/prisma.service';
import { AdminLoginDto } from './dto/admin-login.dto';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AdminAuthService {
    constructor(
        private prisma: PrismaService,
        private jwtService: JwtService,
    ) { }

    async login(loginDto: AdminLoginDto) {
        const { email, password } = loginDto;
        const admin = await this.prisma.admin.findUnique({
            where: { email },
        });

        if (!admin) {
            throw new UnauthorizedException('Invalid credentials');
        }

        if (!admin.isActive) {
            throw new UnauthorizedException('Account is inactive');
        }

        const isPasswordValid = await bcrypt.compare(password, admin.password);
        if (!isPasswordValid) {
            throw new UnauthorizedException('Invalid credentials');
        }

        const payload = {
            sub: admin.id,
            email: admin.email,
            role: admin.role
        };

        return {
            access_token: this.jwtService.sign(payload),
            admin: {
                id: admin.id,
                email: admin.email,
                name: admin.name,
                role: admin.role,
            }
        };
    }
}
