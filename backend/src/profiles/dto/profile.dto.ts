import { IsString, IsNotEmpty, IsInt, IsOptional, Min } from 'class-validator';

export class CreateProfileDto {
    @IsString()
    @IsNotEmpty()
    routerId: string;

    @IsString()
    @IsNotEmpty()
    name: string;

    @IsInt()
    @Min(1)
    @IsOptional()
    sharedUsers?: number = 1;

    @IsString()
    @IsOptional()
    rateLimit?: string; // e.g., "2M/5M"

    @IsString()
    @IsOptional()
    sessionTimeout?: string; // e.g., "1h", "24h"

    @IsString()
    @IsOptional()
    idleTimeout?: string;
}

export class UpdateProfileDto {
    @IsString()
    @IsOptional()
    name?: string;

    @IsInt()
    @Min(1)
    @IsOptional()
    sharedUsers?: number;

    @IsString()
    @IsOptional()
    rateLimit?: string;

    @IsString()
    @IsOptional()
    sessionTimeout?: string;

    @IsString()
    @IsOptional()
    idleTimeout?: string;
}
