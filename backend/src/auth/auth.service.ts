import { Injectable, ConflictException, UnauthorizedException, BadRequestException, Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { RegisterDto, LoginDto } from './dto/auth.dto';
import { UserRole } from '@prisma/client';

@Injectable()
export class AuthService {
    private readonly logger = new Logger(AuthService.name);
    // In-memory store for reset codes (use Redis in production)
    private resetCodes = new Map<string, { code: string; expiresAt: Date }>();

    constructor(
        private prisma: PrismaService,
        private jwtService: JwtService,
        private configService: ConfigService,
    ) { }

    async register(registerDto: RegisterDto) {
        const { email, password, name, role } = registerDto;

        // Check if user already exists
        const existingUser = await this.prisma.user.findUnique({
            where: { email },
        });

        if (existingUser) {
            throw new ConflictException('User with this email already exists');
        }

        // Hash password
        const hashedPassword = await bcrypt.hash(password, 10);

        // Create user
        const user = await this.prisma.user.create({
            data: {
                email,
                password: hashedPassword,
                name,
                role: role || UserRole.OPERATOR,
            },
            select: {
                id: true,
                email: true,
                name: true,
                networkName: true,
                role: true,
                createdAt: true,
            },
        });

        // Log activity
        await this.prisma.activityLog.create({
            data: {
                userId: user.id,
                action: 'USER_REGISTERED',
                details: JSON.stringify({ email: user.email }),
            },
        });

        // Generate tokens
        const tokens = await this.generateTokens(user.id, user.email, user.role);

        return {
            user,
            ...tokens,
        };
    }

    async login(loginDto: LoginDto) {
        const { email, password } = loginDto;

        // Find user
        const user = await this.prisma.user.findUnique({
            where: { email },
        });

        if (!user) {
            throw new UnauthorizedException('Invalid credentials');
        }

        if (!user.isActive) {
            throw new UnauthorizedException('Account is deactivated');
        }

        // Verify password
        const isPasswordValid = await bcrypt.compare(password, user.password);

        if (!isPasswordValid) {
            throw new UnauthorizedException('Invalid credentials');
        }

        // Log activity
        await this.prisma.activityLog.create({
            data: {
                userId: user.id,
                action: 'USER_LOGIN',
                details: JSON.stringify({ email: user.email }),
            },
        });

        // Generate tokens
        const tokens = await this.generateTokens(user.id, user.email, user.role);

        return {
            user: {
                id: user.id,
                email: user.email,
                name: user.name,
                networkName: user.networkName,
                role: user.role,
                isActive: user.isActive,
                createdAt: user.createdAt,
            },
            ...tokens,
        };
    }

    async refreshTokens(refreshToken: string) {
        try {
            // Verify the refresh token
            const refreshSecret = this.configService.get<string>('JWT_REFRESH_SECRET')
                || 'your-refresh-secret-key-change-this-in-production';

            const payload = await this.jwtService.verifyAsync(refreshToken, {
                secret: refreshSecret,
            });

            // Check if user still exists and is active
            const user = await this.prisma.user.findUnique({
                where: { id: payload.sub },
                select: {
                    id: true,
                    email: true,
                    role: true,
                    isActive: true,
                },
            });

            if (!user || !user.isActive) {
                throw new UnauthorizedException('User not found or inactive');
            }

            // Generate new token pair
            const tokens = await this.generateTokens(user.id, user.email, user.role);

            return tokens;
        } catch (error) {
            throw new UnauthorizedException('Invalid or expired refresh token');
        }
    }

    async forgotPassword(email: string) {
        const user = await this.prisma.user.findUnique({ where: { email } });

        // Always return success to prevent email enumeration
        if (!user) {
            return { message: 'If the email exists, a reset code has been sent' };
        }

        // Generate a 6-digit reset code
        const code = Math.floor(100000 + Math.random() * 900000).toString();
        const expiresAt = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes

        this.resetCodes.set(email, { code, expiresAt });

        // Log the code (in production, send via email/SMS)
        this.logger.log(`Password reset code for ${email}: ${code}`);

        return {
            message: 'If the email exists, a reset code has been sent',
            // Only include code in development for testing convenience
            ...(process.env.NODE_ENV !== 'production' && { code }),
        };
    }

    async resetPassword(email: string, code: string, newPassword: string) {
        const stored = this.resetCodes.get(email);

        if (!stored) {
            throw new BadRequestException('No reset code found. Please request a new one.');
        }

        if (new Date() > stored.expiresAt) {
            this.resetCodes.delete(email);
            throw new BadRequestException('Reset code has expired. Please request a new one.');
        }

        if (stored.code !== code) {
            throw new BadRequestException('Invalid reset code');
        }

        // Update password
        const hashedPassword = await bcrypt.hash(newPassword, 10);
        await this.prisma.user.update({
            where: { email },
            data: { password: hashedPassword },
        });

        // Clear the used code
        this.resetCodes.delete(email);

        return { message: 'Password reset successfully. You can now log in.' };
    }

    async getProfile(userId: string) {
        const user = await this.prisma.user.findUnique({
            where: { id: userId },
            select: {
                id: true,
                email: true,
                name: true,
                networkName: true,
                role: true,
                isActive: true,
                createdAt: true,
                updatedAt: true,
                subscription: {
                    select: {
                        status: true,
                        expiresAt: true,
                        plan: {
                            select: {
                                name: true
                            }
                        }
                    }
                }
            },
        });

        return user;
    }

    private async generateTokens(userId: string, email: string, role: UserRole) {
        const payload = { sub: userId, email, role };

        const refreshSecret = this.configService.get<string>('JWT_REFRESH_SECRET')
            || 'your-refresh-secret-key-change-this-in-production';

        const [accessToken, refreshToken] = await Promise.all([
            this.jwtService.signAsync(payload),
            this.jwtService.signAsync(payload, {
                secret: refreshSecret,
                expiresIn: '7d',
            }),
        ]);

        return {
            accessToken,
            refreshToken,
            tokenType: 'Bearer',
        };
    }
}
