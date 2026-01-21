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
    Query,
    Req,
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

    @Get(':id/stats')
    getStats(@Param('id') id: string, @CurrentUser() user: any) {
        return this.routersService.getRouterStats(id, user.id);
    }
}

@Controller('public/routers')
export class PublicRoutersController {
    constructor(private readonly routersService: RoutersService) { }

    @Get('script-callback')
    handleCallback(@Query('ip') ip: string, @Req() req: any) {
        // Fallback if IP not in query (though script uses fetch, it might not send IP in query easily always, 
        // but fetch can be configured. 
        // Ideally, we get IP from request socket if not provided.
        const requestIp = ip || req.ip || req.connection.remoteAddress;

        // Clean up IP (remove ::ffff: prefix if present)
        const cleanIp = requestIp.replace('::ffff:', '');

        return this.routersService.handleScriptCallback(cleanIp);
    }
}
