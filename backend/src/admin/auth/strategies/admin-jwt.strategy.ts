import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { Request } from 'express';
import { PrismaService } from '../../../prisma/prisma.service';

function extractAdminJwtFromCookieOrHeader(req: Request): string | null {
    if (req.cookies?.admin_access_token) {
        return req.cookies.admin_access_token;
    }
    return ExtractJwt.fromAuthHeaderAsBearerToken()(req);
}

@Injectable()
export class AdminJwtStrategy extends PassportStrategy(Strategy, 'admin-jwt') {
    constructor(private prisma: PrismaService) {
        super({
            jwtFromRequest: extractAdminJwtFromCookieOrHeader,
            ignoreExpiration: false,
            secretOrKey: process.env.JWT_SECRET!,
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
