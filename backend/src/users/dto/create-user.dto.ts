import { IsEmail, IsNotEmpty, IsString, MinLength, IsEnum, IsOptional } from 'class-validator';
import { UserRole } from '@prisma/client';

export class CreateUserDto {
    @IsEmail()
    email: string;

    @IsString()
    @MinLength(8)
    password: string;

    @IsString()
    @IsOptional()
    name?: string;

    @IsString()
    @IsOptional()
    networkName?: string;

    @IsEnum(UserRole)
    @IsOptional()
    role?: UserRole; // Default is OPERATOR if not specified
}
