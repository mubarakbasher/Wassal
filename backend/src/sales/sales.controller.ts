import { Controller, Get, Query, UseGuards, Res } from '@nestjs/common';
import type { Response } from 'express';
import { SalesService } from './sales.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { SubscriptionGuard } from '../auth/guards/subscription.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { SalesChartDto } from './dto/sales.dto';

@Controller('sales')
@UseGuards(JwtAuthGuard, SubscriptionGuard)
export class SalesController {
    constructor(private readonly salesService: SalesService) { }

    @Get('chart')
    getSalesChart(@CurrentUser() user: any, @Query() dto: SalesChartDto) {
        return this.salesService.getSalesChart(user.id, dto);
    }

    @Get('history')
    getRecentSales(@CurrentUser() user: any, @Query('limit') limit?: number) {
        return this.salesService.getRecentSales(user.id, limit ? Number(limit) : 10);
    }

    @Get('export/csv')
    async exportCsv(@CurrentUser() user: any, @Res() res: Response) {
        const sales = await this.salesService.getRecentSales(user.id, 1000);

        const headers = ['ID', 'Amount', 'Customer', 'Plan', 'Router', 'Sold At'];
        const rows = sales.map(s => [
            s.id,
            s.amount,
            s.customerName || 'N/A',
            s.planName || '',
            s.routerName || '',
            new Date(s.soldAt).toISOString(),
        ]);

        const csv = [headers.join(','), ...rows.map(r => r.map(c => `"${c}"`).join(','))].join('\n');

        res.setHeader('Content-Type', 'text/csv');
        res.setHeader('Content-Disposition', `attachment; filename=sales-${Date.now()}.csv`);
        res.send(csv);
    }
}
