import { Controller, Get, Param, Query, Patch, Post, Body, UseGuards, Delete, Res, Header } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import type { Response } from 'express';
import { AdminUsersService } from './admin-users.service';
import { AdminJwtAuthGuard } from '../auth/guards/admin-jwt-auth.guard';
import { CreateUserDto } from './dto/admin-user.dto';

@ApiTags('Admin Users')
@ApiBearerAuth('JWT')
@Controller('admin/users')
@UseGuards(AdminJwtAuthGuard)
export class AdminUsersController {
    constructor(private readonly usersService: AdminUsersService) { }

    @Post()
    @ApiOperation({ summary: 'Create a new user' })
    create(@Body() data: CreateUserDto) {
        return this.usersService.createUser(data);
    }

    @Get('export')
    @Header('Content-Type', 'text/csv')
    @Header('Content-Disposition', 'attachment; filename=users.csv')
    @ApiOperation({ summary: 'Export users as CSV' })
    async exportCsv(@Res() res: Response) {
        const csv = await this.usersService.exportUsersCsv();
        res.send(csv);
    }

    @Get()
    @ApiOperation({ summary: 'List all users with pagination' })
    findAll(
        @Query('page') page: string = '1',
        @Query('limit') limit: string = '10',
        @Query('search') search: string
    ) {
        return this.usersService.findAll(+page, +limit, search);
    }

    @Get(':id')
    @ApiOperation({ summary: 'Get a user by ID' })
    findOne(@Param('id') id: string) {
        return this.usersService.findOne(id);
    }

    @Patch(':id/status')
    @ApiOperation({ summary: 'Update user active status' })
    updateStatus(
        @Param('id') id: string,
        @Body('isActive') isActive: boolean
    ) {
        return this.usersService.updateUserStatus(id, isActive);
    }

    @Delete(':userId/routers/:routerId')
    @ApiOperation({ summary: 'Delete a user router' })
    deleteRouter(@Param('routerId') routerId: string) {
        return this.usersService.deleteRouter(routerId);
    }
}

