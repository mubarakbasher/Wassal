import { Controller, Get, Post, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { ContactMessagesService } from './contact-messages.service';
import { CreateContactMessageDto } from './dto/create-message.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@ApiTags('Contact Messages')
@ApiBearerAuth('JWT')
@Controller('contact-messages')
@UseGuards(JwtAuthGuard)
export class ContactMessagesController {
    constructor(private readonly contactMessagesService: ContactMessagesService) {}

    @Post()
    @ApiOperation({ summary: 'Send a contact message' })
    create(@CurrentUser() user: any, @Body() dto: CreateContactMessageDto) {
        return this.contactMessagesService.create(user.id, dto);
    }

    @Get()
    @ApiOperation({ summary: 'Get my contact messages' })
    findMine(@CurrentUser() user: any) {
        return this.contactMessagesService.findByUser(user.id);
    }
}
