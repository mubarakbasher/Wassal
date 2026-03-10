import { IsString, IsNotEmpty, IsOptional, IsNumber, IsBoolean, Min } from 'class-validator';

export class CreatePlanDto {
    @IsString()
    @IsNotEmpty()
    name: string;

    @IsNumber()
    @Min(0)
    price: number;

    @IsNumber()
    @Min(1)
    durationDays: number;

    @IsString()
    @IsOptional()
    description?: string;

    @IsNumber()
    @IsOptional()
    @Min(1)
    maxRouters?: number;

    @IsNumber()
    @IsOptional()
    @Min(0)
    maxHotspotUsers?: number;

    @IsBoolean()
    @IsOptional()
    allowReports?: boolean;

    @IsBoolean()
    @IsOptional()
    allowVouchers?: boolean;
}

export class UpdatePlanDto {
    @IsString()
    @IsOptional()
    name?: string;

    @IsNumber()
    @IsOptional()
    @Min(0)
    price?: number;

    @IsNumber()
    @IsOptional()
    @Min(1)
    durationDays?: number;

    @IsString()
    @IsOptional()
    description?: string;

    @IsNumber()
    @IsOptional()
    @Min(1)
    maxRouters?: number;

    @IsNumber()
    @IsOptional()
    @Min(0)
    maxHotspotUsers?: number;

    @IsBoolean()
    @IsOptional()
    allowReports?: boolean;

    @IsBoolean()
    @IsOptional()
    allowVouchers?: boolean;
}

export class AssignSubscriptionDto {
    @IsString()
    @IsNotEmpty()
    userId: string;

    @IsString()
    @IsNotEmpty()
    planId: string;

    @IsNumber()
    @IsOptional()
    @Min(1)
    durationDays?: number;
}

export class ExtendSubscriptionDto {
    @IsNumber()
    @Min(1)
    days: number;
}
