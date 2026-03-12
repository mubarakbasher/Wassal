import { IsString, IsNotEmpty, MaxLength } from 'class-validator';

export class CreateContactMessageDto {
    @IsString()
    @IsNotEmpty()
    @MaxLength(200)
    subject: string;

    @IsString()
    @IsNotEmpty()
    @MaxLength(5000)
    message: string;
}
