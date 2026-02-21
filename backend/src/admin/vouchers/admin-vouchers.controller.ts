import {
    Controller,
    Get,
    Post,
    Delete,
    Body,
    Param,
    Query,
    UseGuards,
    HttpCode,
    HttpStatus,
} from '@nestjs/common';
import { AdminJwtAuthGuard } from '../auth/guards/admin-jwt-auth.guard';
import { AdminVouchersService } from './admin-vouchers.service';

@Controller('admin/vouchers')
@UseGuards(AdminJwtAuthGuard)
export class AdminVouchersController {
    constructor(private readonly vouchersService: AdminVouchersService) { }

    @Get()
    findAll(@Query('status') status?: string, @Query('routerId') routerId?: string) {
        return this.vouchersService.findAll(status, routerId);
    }

    @Post()
    create(@Body() body: any) {
        return this.vouchersService.create(body);
    }

    @Delete(':id')
    @HttpCode(HttpStatus.OK)
    remove(@Param('id') id: string) {
        return this.vouchersService.remove(id);
    }
}
