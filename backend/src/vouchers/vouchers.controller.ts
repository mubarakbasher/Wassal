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
    Patch,
    Res,
} from '@nestjs/common';
import type { Response } from 'express';
import { VouchersService } from './vouchers.service';
import { CreateVoucherDto, VoucherFilterDto } from './dto/voucher.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { SubscriptionGuard } from '../auth/guards/subscription.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@Controller('vouchers')
@UseGuards(JwtAuthGuard, SubscriptionGuard)
export class VouchersController {
    constructor(private readonly vouchersService: VouchersService) { }

    @Post()
    create(@CurrentUser() user: any, @Body() createVoucherDto: CreateVoucherDto) {
        return this.vouchersService.create(user.id, createVoucherDto);
    }

    @Get()
    findAll(@CurrentUser() user: any, @Query() filter: VoucherFilterDto) {
        return this.vouchersService.findAll(user.id, filter);
    }

    @Get('statistics')
    getStatistics(@CurrentUser() user: any, @Query('routerId') routerId?: string) {
        return this.vouchersService.getStatistics(user.id, routerId);
    }

    @Get('export/csv')
    async exportCsv(
        @CurrentUser() user: any,
        @Query() filter: VoucherFilterDto,
        @Res() res: Response,
    ) {
        const vouchers = await this.vouchersService.findAll(user.id, filter);

        // Build CSV
        const headers = ['Username', 'Password', 'Plan', 'Type', 'Duration (min)', 'Data Limit', 'Price', 'Status', 'Created At', 'Router'];
        const rows = vouchers.map(v => [
            v.username,
            v.password,
            v.planName || '',
            v.planType,
            v.duration || '',
            v.dataLimit || '',
            v.price || '',
            v.status,
            new Date(v.createdAt).toISOString(),
            v.router?.name || '',
        ]);

        const csv = [headers.join(','), ...rows.map(r => r.map(c => `"${c}"`).join(','))].join('\n');

        res.setHeader('Content-Type', 'text/csv');
        res.setHeader('Content-Disposition', `attachment; filename=vouchers-${Date.now()}.csv`);
        res.send(csv);
    }

    @Get(':id')
    findOne(@Param('id') id: string, @CurrentUser() user: any) {
        return this.vouchersService.findOne(id, user.id);
    }

    @Patch(':id/activate')
    activate(@Param('id') id: string, @CurrentUser() user: any) {
        return this.vouchersService.activate(id, user.id);
    }

    @Patch(':id/sell')
    markAsSold(
        @Param('id') id: string,
        @CurrentUser() user: any,
        @Body('customerName') customerName?: string,
        @Body('customerPhone') customerPhone?: string,
    ) {
        return this.vouchersService.markAsSold(id, user.id, customerName, customerPhone);
    }

    @Delete(':id')
    @HttpCode(HttpStatus.OK)
    remove(@Param('id') id: string, @CurrentUser() user: any) {
        return this.vouchersService.remove(id, user.id);
    }
}
