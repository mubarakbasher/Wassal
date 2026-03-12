import { IsString, IsNotEmpty, MaxLength } from 'class-validator';

export class ReplyMessageDto {
    @IsString()
    @IsNotEmpty()
    @MaxLength(5000)
    reply: string;
}
