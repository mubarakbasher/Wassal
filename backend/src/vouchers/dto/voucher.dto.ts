import { IsString, IsNotEmpty, IsEnum, IsInt, IsOptional, Min, IsNumber } from 'class-validator';
import { PlanType } from '@prisma/client';

export enum VoucherCharset {
    NUMERIC = 'NUMERIC',
    ALPHANUMERIC = 'ALPHANUMERIC',
    ALPHA = 'ALPHA',
}

export enum VoucherAuthType {
    USER_PASS = 'USER_PASS',
    USER_SAME_PASS = 'USER_SAME_PASS',
    USERNAME_ONLY = 'USERNAME_ONLY',
}

export class CreateVoucherDto {
    @IsString()
    @IsNotEmpty()
    routerId: string;

    @IsString()
    @IsOptional()
    profileId?: string;

    @IsString()
    @IsOptional()
    mikrotikProfile?: string;

    @IsEnum(PlanType)
    planType: PlanType;

    @IsString()
    @IsNotEmpty()
    planName: string;

    @IsInt()
    @Min(1)
    @IsOptional()
    duration?: number; // Duration in minutes (for TIME_BASED)

    @IsNumber()
    @Min(1)
    @IsOptional()
    dataLimit?: number; // Data limit in bytes (for DATA_BASED)

    @IsNumber()
    @Min(0)
    price: number;

    @IsInt()
    @Min(1)
    @IsOptional()
    quantity?: number = 1; // For bulk generation

    @IsEnum(VoucherCharset)
    @IsOptional()
    charset?: VoucherCharset = VoucherCharset.NUMERIC;

    @IsEnum(VoucherAuthType)
    @IsOptional()
    authType?: VoucherAuthType = VoucherAuthType.USER_SAME_PASS;
}

export class UpdateVoucherStatusDto {
    @IsEnum(['UNUSED', 'ACTIVE', 'EXPIRED', 'SOLD'])
    status: string;
}

export class VoucherFilterDto {
    @IsString()
    @IsOptional()
    routerId?: string;

    @IsEnum(['UNUSED', 'ACTIVE', 'EXPIRED', 'SOLD'])
    @IsOptional()
    status?: string;

    @IsEnum(PlanType)
    @IsOptional()
    planType?: PlanType;
}
