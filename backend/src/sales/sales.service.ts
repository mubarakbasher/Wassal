import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { SalesChartDto, SalesRange } from './dto/sales.dto';

@Injectable()
export class SalesService {
    constructor(private prisma: PrismaService) { }

    async getSalesChart(userId: string, dto: SalesChartDto) {
        const { range, routerId } = dto;
        const now = new Date();
        const where: any = {
            userId,
            ...(routerId && {
                voucher: {
                    routerId,
                },
            }),
        };

        let startDate: Date;
        let dateFormat: (date: Date) => string;

        if (range === SalesRange.DAILY) {
            // Last 30 days
            startDate = new Date();
            startDate.setDate(now.getDate() - 30);
            dateFormat = (d) => d.toISOString().split('T')[0]; // YYYY-MM-DD
        } else {
            // Last 12 months
            startDate = new Date();
            startDate.setFullYear(now.getFullYear() - 1);
            dateFormat = (d) => `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`; // YYYY-MM
        }

        where.soldAt = {
            gte: startDate,
        };

        const sales = await this.prisma.sale.findMany({
            where,
            orderBy: {
                soldAt: 'asc',
            },
            select: {
                amount: true,
                soldAt: true,
            },
        });

        // Aggregate data
        const aggregated = sales.reduce((acc, sale) => {
            const key = dateFormat(sale.soldAt);
            if (!acc[key]) {
                acc[key] = 0;
            }
            acc[key] += Number(sale.amount);
            return acc;
        }, {} as Record<string, number>);

        // Fill missing dates
        const result: { date: string; amount: number }[] = [];
        const current = new Date(startDate);
        while (current <= now) {
            const key = dateFormat(current);
            result.push({
                date: key,
                amount: aggregated[key] || 0,
            });
            if (range === SalesRange.DAILY) {
                current.setDate(current.getDate() + 1);
            } else {
                current.setMonth(current.getMonth() + 1);
            }
        }

        return result;
    }

    async getRecentSales(userId: string, limit: number = 10) {
        const sales = await this.prisma.sale.findMany({
            where: { userId },
            orderBy: { soldAt: 'desc' },
            take: limit,
            include: {
                voucher: {
                    select: {
                        planName: true,
                        router: {
                            select: {
                                name: true,
                            },
                        },
                    },
                },
            },
        });

        return sales.map(sale => ({
            id: sale.id,
            amount: Number(sale.amount),
            customerName: sale.customerName,
            soldAt: sale.soldAt,
            planName: sale.voucher.planName,
            routerName: sale.voucher.router.name,
        }));
    }
}
