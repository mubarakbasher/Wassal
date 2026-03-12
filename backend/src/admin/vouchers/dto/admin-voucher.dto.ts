import { IsString, IsNotEmpty, IsOptional, IsNumber, IsIn, Min, Max } from 'class-validator';

export class CreateVoucherDto {
    @IsString()
    @IsNotEmpty()
    routerId: string;

    @IsString()
    @IsOptional()
    mikrotikProfile?: string;

    @IsString()
    @IsNotEmpty()
    @IsIn(['TIME_BASED', 'DATA_BASED', 'UNLIMITED'])
    planType: string;

    @IsString()
    @IsOptional()
    @IsIn(['WALL_CLOCK', 'ONLINE_ONLY'])
    countType?: string;

    @IsString()
    @IsNotEmpty()
    planName: string;

    @IsNumber()
    @IsOptional()
    @Min(1)
    duration?: number;

    @IsNumber()
    @IsOptional()
    @Min(1)
    dataLimit?: number;

    @IsNumber()
    @Min(0)
    price: number;

    @IsNumber()
    @IsOptional()
    @Min(1)
    @Max(500)
    quantity?: number;
}
