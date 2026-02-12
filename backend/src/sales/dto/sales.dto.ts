import { IsEnum, IsOptional, IsString } from 'class-validator';

export enum SalesRange {
    DAILY = 'DAILY',
    MONTHLY = 'MONTHLY',
}

export class SalesChartDto {
    @IsEnum(SalesRange)
    range: SalesRange;

    @IsOptional()
    @IsString()
    routerId?: string;
}
