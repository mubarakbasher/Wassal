import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { AdminAuthController } from './admin-auth.controller';
import { AdminAuthService } from './admin-auth.service';
import { AdminJwtStrategy } from './strategies/admin-jwt.strategy';
import { PrismaModule } from '../../prisma/prisma.module';

@Module({
    imports: [
        PrismaModule,
        PassportModule,
        JwtModule.registerAsync({
            imports: [ConfigModule],
            useFactory: async (configService: ConfigService) => ({
                secret: configService.get<string>('JWT_SECRET') || 'your-super-secret-jwt-key-change-this-in-production',
                signOptions: {
                    expiresIn: '1d',
                },
            }),
            inject: [ConfigService],
        }),
    ],
    controllers: [AdminAuthController],
    providers: [AdminAuthService, AdminJwtStrategy],
    exports: [AdminAuthService],
})
export class AdminAuthModule { }
