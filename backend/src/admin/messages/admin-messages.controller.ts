import { Controller, Get, Patch, Param, Body, Query, UseGuards } from '@nestjs/common';
import { AdminMessagesService } from './admin-messages.service';
import { AdminJwtAuthGuard } from '../auth/guards/admin-jwt-auth.guard';

@Controller('admin/messages')
@UseGuards(AdminJwtAuthGuard)
export class AdminMessagesController {
    constructor(private readonly messagesService: AdminMessagesService) {}

    @Get('stats')
    getStats() {
        return this.messagesService.getStats();
    }

    @Get()
    findAll(
        @Query('page') page: string = '1',
        @Query('status') status?: string,
        @Query('search') search?: string,
    ) {
        return this.messagesService.findAll(+page, 10, status, search);
    }

    @Get(':id')
    findOne(@Param('id') id: string) {
        return this.messagesService.findOne(id);
    }

    @Patch(':id/read')
    markAsRead(@Param('id') id: string) {
        return this.messagesService.markAsRead(id);
    }

    @Patch(':id/reply')
    reply(@Param('id') id: string, @Body() body: { reply: string }) {
        return this.messagesService.reply(id, body.reply);
    }
}
