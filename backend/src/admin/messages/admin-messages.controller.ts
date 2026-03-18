import { Controller, Get, Patch, Param, Body, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AdminMessagesService } from './admin-messages.service';
import { AdminJwtAuthGuard } from '../auth/guards/admin-jwt-auth.guard';
import { ReplyMessageDto } from './dto/reply-message.dto';

@ApiTags('Admin Messages')
@ApiBearerAuth('JWT')
@Controller('admin/messages')
@UseGuards(AdminJwtAuthGuard)
export class AdminMessagesController {
    constructor(private readonly messagesService: AdminMessagesService) {}

    @Get('stats')
    @ApiOperation({ summary: 'Get message statistics' })
    getStats() {
        return this.messagesService.getStats();
    }

    @Get()
    @ApiOperation({ summary: 'List all messages with pagination' })
    findAll(
        @Query('page') page: string = '1',
        @Query('status') status?: string,
        @Query('search') search?: string,
    ) {
        return this.messagesService.findAll(+page || 1, 10, status, search);
    }

    @Get(':id')
    @ApiOperation({ summary: 'Get a message by ID' })
    findOne(@Param('id') id: string) {
        return this.messagesService.findOne(id);
    }

    @Patch(':id/read')
    @ApiOperation({ summary: 'Mark a message as read' })
    markAsRead(@Param('id') id: string) {
        return this.messagesService.markAsRead(id);
    }

    @Patch(':id/reply')
    @ApiOperation({ summary: 'Reply to a message' })
    reply(@Param('id') id: string, @Body() dto: ReplyMessageDto) {
        return this.messagesService.reply(id, dto.reply);
    }
}
