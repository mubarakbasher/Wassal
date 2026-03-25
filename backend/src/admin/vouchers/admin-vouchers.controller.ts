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
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AdminJwtAuthGuard } from '../auth/guards/admin-jwt-auth.guard';
import { AdminVouchersService } from './admin-vouchers.service';
import { CreateVoucherDto } from './dto/admin-voucher.dto';

@ApiTags('Admin Vouchers')
@ApiBearerAuth('JWT')
@Controller('admin/vouchers')
@UseGuards(AdminJwtAuthGuard)
export class AdminVouchersController {
    constructor(private readonly vouchersService: AdminVouchersService) { }

    @Get()
    @ApiOperation({ summary: 'List vouchers with pagination' })
    findAll(
        @Query('page') page: string = '1',
        @Query('limit') limit: string = '20',
        @Query('status') status?: string,
        @Query('routerId') routerId?: string,
        @Query('search') search?: string,
    ) {
        return this.vouchersService.findAll(+page, +limit, status, routerId, search);
    }

    @Post()
    @ApiOperation({ summary: 'Create vouchers' })
    create(@Body() body: CreateVoucherDto) {
        return this.vouchersService.create(body);
    }

    @Delete(':id')
    @HttpCode(HttpStatus.OK)
    @ApiOperation({ summary: 'Delete a voucher' })
    remove(@Param('id') id: string) {
        return this.vouchersService.remove(id);
    }
}
