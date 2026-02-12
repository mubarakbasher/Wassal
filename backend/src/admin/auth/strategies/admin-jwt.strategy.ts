import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { PrismaService } from '../../../prisma/prisma.service';

@Injectable()
export class AdminJwtStrategy extends PassportStrategy(Strategy, 'admin-jwt') {
    constructor(private prisma: PrismaService) {
        super({
            jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
            ignoreExpiration: false,
            secretOrKey: process.env.JWT_SECRET || 'your-super-secret-jwt-key-change-this-in-production',
        });
    }

    async validate(payload: any) {
        const admin = await this.prisma.admin.findUnique({
            where: { id: payload.sub },
            select: {
                id: true,
                email: true,
                name: true,
                role: true,
                isActive: true,
            },
        });

        if (!admin || !admin.isActive) {
            throw new UnauthorizedException('Admin account is inactive or not found');
        }

        return admin;
    }
}
