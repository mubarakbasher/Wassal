import { Controller, Get, Patch, Param, Body, Query, UseGuards, Request, Res, Header } from '@nestjs/common';
import type { Response } from 'express';
import { AdminPaymentsService } from './admin-payments.service';
import { AdminJwtAuthGuard } from '../auth/guards/admin-jwt-auth.guard';

@Controller('admin/payments')
@UseGuards(AdminJwtAuthGuard)
export class AdminPaymentsController {
    constructor(private readonly paymentsService: AdminPaymentsService) { }

    @Get('export')
    @Header('Content-Type', 'text/csv')
    @Header('Content-Disposition', 'attachment; filename=payments.csv')
    async exportCsv(@Res() res: Response) {
        const csv = await this.paymentsService.exportPaymentsCsv();
        res.send(csv);
    }

    @Get()
    findAll(
        @Query('page') page: string = '1',
        @Query('status') status: string
    ) {
        return this.paymentsService.findAll(+page, 10, status);
    }

    @Patch(':id/review')
    reviewPayment(
        @Param('id') id: string,
        @Body() body: { status: 'APPROVED' | 'REJECTED', notes?: string },
        @Request() req: any
    ) {
        const adminId = req.user.id;
        return this.paymentsService.reviewPayment(id, adminId, body.status, body.notes);
    }
}
