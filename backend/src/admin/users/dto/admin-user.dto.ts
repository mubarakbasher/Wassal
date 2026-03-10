import { IsString, IsEmail, IsNotEmpty, IsOptional, MinLength, IsIn } from 'class-validator';

export class CreateUserDto {
    @IsEmail()
    @IsNotEmpty()
    email: string;

    @IsString()
    @IsNotEmpty()
    @MinLength(6)
    password: string;

    @IsString()
    @IsOptional()
    name?: string;

    @IsString()
    @IsOptional()
    networkName?: string;

    @IsString()
    @IsOptional()
    @IsIn(['ADMIN', 'OPERATOR', 'RESELLER'])
    role?: string;
}
