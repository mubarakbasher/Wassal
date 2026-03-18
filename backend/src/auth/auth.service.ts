import { Injectable, ConflictException, UnauthorizedException, BadRequestException, NotFoundException, Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcrypt';
import { randomInt, randomUUID } from 'crypto';
import { PrismaService } from '../prisma/prisma.service';
import { EmailService } from '../email/email.service';
import { RegisterDto, LoginDto } from './dto/auth.dto';
import { UserRole } from '@prisma/client';

@Injectable()
export class AuthService {
    private readonly logger = new Logger(AuthService.name);

    constructor(
        private prisma: PrismaService,
        private jwtService: JwtService,
        private configService: ConfigService,
        private emailService: EmailService,
    ) { }

    async register(registerDto: RegisterDto) {
        const { email, password, name, role } = registerDto;

        const existingUser = await this.prisma.user.findUnique({
            where: { email },
        });

        if (existingUser) {
            throw new ConflictException('User with this email already exists');
        }

        const hashedPassword = await bcrypt.hash(password, 10);

        const user = await this.prisma.user.create({
            data: {
                email,
                password: hashedPassword,
                name,
                role: role || UserRole.OPERATOR,
                emailVerified: false,
            },
            select: {
                id: true,
                email: true,
                name: true,
                networkName: true,
                role: true,
                emailVerified: true,
                createdAt: true,
            },
        });

        await this.prisma.activityLog.create({
            data: {
                userId: user.id,
                action: 'USER_REGISTERED',
                details: JSON.stringify({ email: user.email }),
            },
        });

        // Send email verification
        await this.sendVerificationEmail(user.email);

        const tokens = await this.generateTokens(user.id, user.email, user.role);

        return {
            user,
            ...tokens,
        };
    }

    async login(loginDto: LoginDto) {
        const { email, password } = loginDto;

        const user = await this.prisma.user.findUnique({
            where: { email },
        });

        if (!user) {
            throw new UnauthorizedException('Invalid credentials');
        }

        if (!user.isActive) {
            throw new UnauthorizedException('Account is deactivated');
        }

        const isPasswordValid = await bcrypt.compare(password, user.password);

        if (!isPasswordValid) {
            throw new UnauthorizedException('Invalid credentials');
        }

        await this.prisma.activityLog.create({
            data: {
                userId: user.id,
                action: 'USER_LOGIN',
                details: JSON.stringify({ email: user.email }),
            },
        });

        const tokens = await this.generateTokens(user.id, user.email, user.role);

        return {
            user: {
                id: user.id,
                email: user.email,
                name: user.name,
                networkName: user.networkName,
                role: user.role,
                isActive: user.isActive,
                emailVerified: user.emailVerified,
                createdAt: user.createdAt,
            },
            ...tokens,
        };
    }

    async refreshTokens(refreshToken: string) {
        try {
            const refreshSecret = this.configService.get<string>('JWT_REFRESH_SECRET');

            const payload = await this.jwtService.verifyAsync(refreshToken, {
                secret: refreshSecret,
            });

            // Check if the refresh token exists in DB and is not revoked
            const storedToken = await this.prisma.refreshToken.findUnique({
                where: { token: refreshToken },
            });

            if (!storedToken || storedToken.revoked || storedToken.expiresAt < new Date()) {
                throw new UnauthorizedException('Refresh token has been revoked or expired');
            }

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

            // Revoke old refresh token (token rotation)
            await this.prisma.refreshToken.update({
                where: { id: storedToken.id },
                data: { revoked: true, revokedAt: new Date() },
            });

            const tokens = await this.generateTokens(user.id, user.email, user.role);

            return tokens;
        } catch (error) {
            if (error instanceof UnauthorizedException) throw error;
            throw new UnauthorizedException('Invalid or expired refresh token');
        }
    }

    /**
     * Revoke all refresh tokens for a user (e.g., on password change or logout-all)
     */
    async revokeAllTokens(userId: string) {
        await this.prisma.refreshToken.updateMany({
            where: { userId, revoked: false },
            data: { revoked: true, revokedAt: new Date() },
        });
    }

    async forgotPassword(email: string) {
        const user = await this.prisma.user.findUnique({ where: { email } });

        if (!user) {
            throw new NotFoundException('No account found with this email');
        }

        const code = randomInt(100000, 999999).toString();
        const expiresAt = new Date(Date.now() + 15 * 60 * 1000);

        // Invalidate previous codes for this email
        await this.prisma.passwordResetCode.updateMany({
            where: { email, used: false },
            data: { used: true },
        });

        await this.prisma.passwordResetCode.create({
            data: { email, code, expiresAt },
        });

        try {
            await this.emailService.sendResetCode(email, code);
        } catch (error) {
            this.logger.error(`Failed to send reset email to ${email}`, error);
        }

        return {
            message: 'If the email exists, a reset code has been sent',
        };
    }

    async resetPassword(email: string, code: string, newPassword: string) {
        const stored = await this.prisma.passwordResetCode.findFirst({
            where: { email, used: false },
            orderBy: { createdAt: 'desc' },
        });

        if (!stored) {
            throw new BadRequestException('No reset code found. Please request a new one.');
        }

        if (new Date() > stored.expiresAt) {
            await this.prisma.passwordResetCode.update({
                where: { id: stored.id },
                data: { used: true },
            });
            throw new BadRequestException('Reset code has expired. Please request a new one.');
        }

        if (stored.code !== code) {
            throw new BadRequestException('Invalid reset code');
        }

        const hashedPassword = await bcrypt.hash(newPassword, 10);
        await this.prisma.user.update({
            where: { email },
            data: { password: hashedPassword },
        });

        // Mark code as used
        await this.prisma.passwordResetCode.update({
            where: { id: stored.id },
            data: { used: true },
        });

        // Revoke all refresh tokens on password reset
        const user = await this.prisma.user.findUnique({ where: { email } });
        if (user) {
            await this.revokeAllTokens(user.id);
        }

        return { message: 'Password reset successfully. You can now log in.' };
    }

    // ---- Email Verification ----

    async sendVerificationEmail(email: string) {
        const token = randomUUID();
        const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24 hours

        // Invalidate previous tokens
        await this.prisma.emailVerificationToken.updateMany({
            where: { email, used: false },
            data: { used: true },
        });

        await this.prisma.emailVerificationToken.create({
            data: { email, token, expiresAt },
        });

        try {
            await this.emailService.sendVerificationEmail(email, token);
        } catch (error) {
            this.logger.error(`Failed to send verification email to ${email}`, error);
        }

        return { message: 'Verification email sent' };
    }

    async verifyEmail(token: string) {
        const stored = await this.prisma.emailVerificationToken.findUnique({
            where: { token },
        });

        if (!stored || stored.used) {
            throw new BadRequestException('Invalid or already used verification token');
        }

        if (new Date() > stored.expiresAt) {
            throw new BadRequestException('Verification token has expired. Please request a new one.');
        }

        await this.prisma.user.update({
            where: { email: stored.email },
            data: { emailVerified: true },
        });

        await this.prisma.emailVerificationToken.update({
            where: { id: stored.id },
            data: { used: true },
        });

        return { message: 'Email verified successfully' };
    }

    async resendVerification(email: string) {
        const user = await this.prisma.user.findUnique({ where: { email } });

        if (!user) {
            throw new NotFoundException('User not found');
        }

        if (user.emailVerified) {
            throw new BadRequestException('Email is already verified');
        }

        return this.sendVerificationEmail(email);
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
                emailVerified: true,
                notifyRouterStatus: true,
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

        const refreshSecret = this.configService.get<string>('JWT_REFRESH_SECRET');

        const [accessToken, refreshTokenJwt] = await Promise.all([
            this.jwtService.signAsync(payload),
            this.jwtService.signAsync(payload, {
                secret: refreshSecret,
                expiresIn: '90d',
            }),
        ]);

        // Persist refresh token in DB for revocation support
        await this.prisma.refreshToken.create({
            data: {
                token: refreshTokenJwt,
                userId,
                expiresAt: new Date(Date.now() + 90 * 24 * 60 * 60 * 1000),
            },
        });

        return {
            accessToken,
            refreshToken: refreshTokenJwt,
            tokenType: 'Bearer',
        };
    }
}
