import {
    Controller,
    Get,
    Post,
    Put,
    Delete,
    Body,
    Param,
    UseGuards,
    HttpCode,
    HttpStatus,
} from '@nestjs/common';
import { RoutersService } from './routers.service';
import { CreateRouterDto, UpdateRouterDto } from './dto/router.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@Controller('routers')
@UseGuards(JwtAuthGuard)
export class RoutersController {
    constructor(private readonly routersService: RoutersService) { }

    @Post()
    create(@CurrentUser() user: any, @Body() createRouterDto: CreateRouterDto) {
        return this.routersService.create(user.id, createRouterDto);
    }

    @Get()
    findAll(@CurrentUser() user: any) {
        return this.routersService.findAll(user.id);
    }

    @Get(':id')
    findOne(@Param('id') id: string, @CurrentUser() user: any) {
        return this.routersService.findOne(id, user.id);
    }

    @Put(':id')
    update(
        @Param('id') id: string,
        @CurrentUser() user: any,
        @Body() updateRouterDto: UpdateRouterDto,
    ) {
        return this.routersService.update(id, user.id, updateRouterDto);
    }

    @Delete(':id')
    @HttpCode(HttpStatus.OK)
    remove(@Param('id') id: string, @CurrentUser() user: any) {
        return this.routersService.remove(id, user.id);
    }

    @Get(':id/health')
    checkHealth(@Param('id') id: string, @CurrentUser() user: any) {
        return this.routersService.checkHealth(id, user.id);
    }

    @Get(':id/system-info')
    getSystemInfo(@Param('id') id: string, @CurrentUser() user: any) {
        return this.routersService.getSystemInfo(id, user.id);
    }
}
