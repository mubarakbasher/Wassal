import {
    Controller,
    Get,
    Post,
    Patch,
    Delete,
    Body,
    Param,
    UseGuards,
    HttpCode,
    HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AdminJwtAuthGuard } from '../auth/guards/admin-jwt-auth.guard';
import { AdminRoutersService } from './admin-routers.service';
import { CreateRouterDto, UpdateRouterDto } from './dto/admin-router.dto';

@ApiTags('Admin Routers')
@ApiBearerAuth('JWT')
@Controller('admin/routers')
@UseGuards(AdminJwtAuthGuard)
export class AdminRoutersController {
    constructor(private readonly routersService: AdminRoutersService) { }

    @Get()
    @ApiOperation({ summary: 'List all routers' })
    findAll() {
        return this.routersService.findAll();
    }

    @Get(':id')
    @ApiOperation({ summary: 'Get a router by ID' })
    findOne(@Param('id') id: string) {
        return this.routersService.findOne(id);
    }

    @Post()
    @ApiOperation({ summary: 'Create a new router' })
    create(@Body() body: CreateRouterDto) {
        return this.routersService.create(body);
    }

    @Patch(':id')
    @ApiOperation({ summary: 'Update a router' })
    update(@Param('id') id: string, @Body() body: UpdateRouterDto) {
        return this.routersService.update(id, body);
    }

    @Delete(':id')
    @HttpCode(HttpStatus.OK)
    @ApiOperation({ summary: 'Delete a router' })
    remove(@Param('id') id: string) {
        return this.routersService.remove(id);
    }

    @Get(':id/status')
    @ApiOperation({ summary: 'Check router connection status' })
    checkStatus(@Param('id') id: string) {
        return this.routersService.checkStatus(id);
    }

    @Get(':id/profiles/mikrotik')
    @ApiOperation({ summary: 'Get MikroTik profiles for a router' })
    getMikrotikProfiles(@Param('id') id: string) {
        return this.routersService.getMikrotikProfiles(id);
    }

    @Post(':id/configure-login')
    @ApiOperation({ summary: 'Configure login page on a router' })
    configureLoginPage(@Param('id') id: string) {
        return this.routersService.configureLoginPage(id);
    }
}
