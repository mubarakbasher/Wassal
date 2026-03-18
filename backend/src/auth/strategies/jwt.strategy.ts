import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { Request } from 'express';
import { PrismaService } from '../../prisma/prisma.service';

function extractJwtFromCookieOrHeader(req: Request): string | null {
    // Try httpOnly cookie first, then fall back to Authorization header (for mobile clients)
    if (req.cookies?.access_token) {
        return req.cookies.access_token;
    }
    return ExtractJwt.fromAuthHeaderAsBearerToken()(req);
}

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
    constructor(private prisma: PrismaService) {
        super({
            jwtFromRequest: extractJwtFromCookieOrHeader,
            ignoreExpiration: false,
            secretOrKey: process.env.JWT_SECRET!,
        });
    }

    async validate(payload: any) {
        const user = await this.prisma.user.findUnique({
            where: { id: payload.sub },
            select: {
                id: true,
                email: true,
                name: true,
                role: true,
                isActive: true,
            },
        });

        if (!user || !user.isActive) {
            throw new UnauthorizedException();
        }

        return user;
    }
}
