import { IsEmail, IsNotEmpty, IsString, MinLength, IsEnum, IsOptional } from 'class-validator';
import { UserRole } from '@prisma/client';

export class RegisterDto {
    @IsEmail()
    email: string;

    @IsString()
    @MinLength(8)
    password: string;

    @IsString()
    @IsOptional()
    name?: string;

    @IsEnum(UserRole)
    @IsOptional()
    role?: UserRole;
}

export class LoginDto {
    @IsEmail()
    email: string;

    @IsString()
    @IsNotEmpty()
    password: string;
}

export class RefreshTokenDto {
    @IsString()
    @IsNotEmpty()
    refreshToken: string;
}

export class ForgotPasswordDto {
    @IsEmail()
    email: string;
}

export class ResetPasswordDto {
    @IsEmail()
    email: string;

    @IsString()
    @IsNotEmpty()
    code: string;

    @IsString()
    @MinLength(8)
    newPassword: string;
}