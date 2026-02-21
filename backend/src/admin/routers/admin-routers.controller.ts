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
import { AdminJwtAuthGuard } from '../auth/guards/admin-jwt-auth.guard';
import { AdminRoutersService } from './admin-routers.service';

@Controller('admin/routers')
@UseGuards(AdminJwtAuthGuard)
export class AdminRoutersController {
    constructor(private readonly routersService: AdminRoutersService) { }

    @Get()
    findAll() {
        return this.routersService.findAll();
    }

    @Get(':id')
    findOne(@Param('id') id: string) {
        return this.routersService.findOne(id);
    }

    @Post()
    create(@Body() body: any) {
        return this.routersService.create(body);
    }

    @Patch(':id')
    update(@Param('id') id: string, @Body() body: any) {
        return this.routersService.update(id, body);
    }

    @Delete(':id')
    @HttpCode(HttpStatus.OK)
    remove(@Param('id') id: string) {
        return this.routersService.remove(id);
    }

    @Get(':id/profiles/mikrotik')
    getMikrotikProfiles(@Param('id') id: string) {
        return this.routersService.getMikrotikProfiles(id);
    }

    @Post(':id/configure-login')
    configureLoginPage(@Param('id') id: string) {
        return this.routersService.configureLoginPage(id);
    }
}
