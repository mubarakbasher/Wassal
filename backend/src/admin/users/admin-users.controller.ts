import { Controller, Get, Param, Query, Patch, Post, Body, UseGuards, Delete, Res, Header } from '@nestjs/common';
import type { Response } from 'express';
import { AdminUsersService } from './admin-users.service';
import { AdminJwtAuthGuard } from '../auth/guards/admin-jwt-auth.guard';

@Controller('admin/users')
@UseGuards(AdminJwtAuthGuard)
export class AdminUsersController {
    constructor(private readonly usersService: AdminUsersService) { }

    @Post()
    create(@Body() data: any) {
        return this.usersService.createUser(data);
    }

    @Get('export')
    @Header('Content-Type', 'text/csv')
    @Header('Content-Disposition', 'attachment; filename=users.csv')
    async exportCsv(@Res() res: Response) {
        const csv = await this.usersService.exportUsersCsv();
        res.send(csv);
    }

    @Get()
    findAll(
        @Query('page') page: string = '1',
        @Query('limit') limit: string = '10',
        @Query('search') search: string
    ) {
        return this.usersService.findAll(+page, +limit, search);
    }

    @Get(':id')
    findOne(@Param('id') id: string) {
        return this.usersService.findOne(id);
    }

    @Patch(':id/status')
    updateStatus(
        @Param('id') id: string,
        @Body('isActive') isActive: boolean
    ) {
        return this.usersService.updateUserStatus(id, isActive);
    }
    @Delete(':userId/routers/:routerId')
    deleteRouter(@Param('routerId') routerId: string) {
        return this.usersService.deleteRouter(routerId);
    }
}

