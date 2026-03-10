import { IsString, IsNotEmpty, IsOptional, IsNumber, IsIP, IsIn } from 'class-validator';

export class CreateRouterDto {
    @IsString()
    @IsNotEmpty()
    name: string;

    @IsIP()
    @IsNotEmpty()
    ipAddress: string;

    @IsNumber()
    @IsOptional()
    apiPort?: number;

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

    @IsString()
    @IsOptional()
    userId?: string;
}

export class UpdateRouterDto {
    @IsString()
    @IsOptional()
    name?: string;

    @IsIP()
    @IsOptional()
    ipAddress?: string;

    @IsNumber()
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

    @IsString()
    @IsOptional()
    @IsIn(['ONLINE', 'OFFLINE', 'ERROR'])
    status?: string;

    @IsString()
    @IsOptional()
    userId?: string;
}
