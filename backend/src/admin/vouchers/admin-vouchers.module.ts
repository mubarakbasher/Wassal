import { Module } from '@nestjs/common';
import { AdminVouchersController } from './admin-vouchers.controller';
import { AdminVouchersService } from './admin-vouchers.service';
import { PrismaModule } from '../../prisma/prisma.module';
import { RadiusModule } from '../../radius/radius.module';
import { AdminAuthModule } from '../auth/admin-auth.module';

@Module({
    imports: [PrismaModule, RadiusModule, AdminAuthModule],
    controllers: [AdminVouchersController],
    providers: [AdminVouchersService],
})
export class AdminVouchersModule { }
