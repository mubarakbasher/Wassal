import { IsString, IsNotEmpty, IsInt, IsOptional, Min, Max } from 'class-validator';

export class CreateRouterDto {
    @IsString()
    @IsNotEmpty()
    name: string;

    @IsString()
    @IsNotEmpty()
    ipAddress: string;

    @IsInt()
    @Min(1)
    @Max(65535)
    @IsOptional()
    apiPort?: number = 8728;

    @IsString()
    @IsNotEmpty()
    username: string;

    @IsString()
    @IsNotEmpty()
    password: string;

    @IsString()
    @IsOptional()
    description?: string;

    @IsString()
    @IsOptional()
    location?: string;
}

export class UpdateRouterDto {
    @IsString()
    @IsOptional()
    name?: string;

    @IsString()
    @IsOptional()
    ipAddress?: string;

    @IsInt()
    @Min(1)
    @Max(65535)
    @IsOptional()
    apiPort?: number;

    @IsString()
    @IsOptional()
    username?: string;

    @IsString()
    @IsOptional()
    password?: string;

    @IsString()
    @IsOptional()
    description?: string;

    @IsString()
    @IsOptional()
    location?: string;
}
