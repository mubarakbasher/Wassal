import { Controller, Get, Post, Body, UseGuards } from '@nestjs/common';
import { ContactMessagesService } from './contact-messages.service';
import { CreateContactMessageDto } from './dto/create-message.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@Controller('contact-messages')
@UseGuards(JwtAuthGuard)
export class ContactMessagesController {
    constructor(private readonly contactMessagesService: ContactMessagesService) {}

    @Post()
    create(@CurrentUser() user: any, @Body() dto: CreateContactMessageDto) {
        return this.contactMessagesService.create(user.id, dto);
    }

    @Get()
    findMine(@CurrentUser() user: any) {
        return this.contactMessagesService.findByUser(user.id);
    }
}
