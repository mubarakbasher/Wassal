import { Module } from '@nestjs/common';
import { AdminPaymentsController } from './admin-payments.controller';
import { AdminPaymentsService } from './admin-payments.service';
import { PrismaModule } from '../../prisma/prisma.module';

@Module({
    imports: [PrismaModule],
    controllers: [AdminPaymentsController],
    providers: [AdminPaymentsService],
})
export class AdminPaymentsModule { }
