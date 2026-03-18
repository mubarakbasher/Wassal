import { IsEmail, IsNotEmpty, IsString, MinLength, IsEnum, IsOptional } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { UserRole } from '@prisma/client';

export class RegisterDto {
    @ApiProperty({ example: 'user@example.com' })
    @IsEmail()
    email: string;

    @ApiProperty({ example: 'securePass123', minLength: 8 })
    @IsString()
    @MinLength(8)
    password: string;

    @ApiPropertyOptional({ example: 'John Doe' })
    @IsString()
    @IsOptional()
    name?: string;

    @ApiPropertyOptional({ enum: UserRole, default: UserRole.OPERATOR })
    @IsEnum(UserRole)
    @IsOptional()
    role?: UserRole;
}

export class LoginDto {
    @ApiProperty({ example: 'user@example.com' })
    @IsEmail()
    email: string;

    @ApiProperty({ example: 'securePass123' })
    @IsString()
    @IsNotEmpty()
    password: string;
}

export class RefreshTokenDto {
    @ApiProperty()
    @IsString()
    @IsNotEmpty()
    refreshToken: string;
}

export class ForgotPasswordDto {
    @ApiProperty({ example: 'user@example.com' })
    @IsEmail()
    email: string;
}

export class ResetPasswordDto {
    @ApiProperty({ example: 'user@example.com' })
    @IsEmail()
    email: string;

    @ApiProperty({ example: '123456' })
    @IsString()
    @IsNotEmpty()
    code: string;

    @ApiProperty({ example: 'newSecurePass123', minLength: 8 })
    @IsString()
    @MinLength(8)
    newPassword: string;
}

export class VerifyEmailDto {
    @ApiProperty({ description: 'Verification token from the email link' })
    @IsString()
    @IsNotEmpty()
    token: string;
}

export class ResendVerificationDto {
    @ApiProperty({ example: 'user@example.com' })
    @IsEmail()
    email: string;
}