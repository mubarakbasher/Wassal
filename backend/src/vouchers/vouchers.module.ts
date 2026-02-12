import { Module } from '@nestjs/common';
import { VouchersController } from './vouchers.controller';
import { VouchersService } from './vouchers.service';
import { PrismaModule } from '../prisma/prisma.module';
import { MikroTikModule } from '../mikrotik/mikrotik.module';
import { RoutersModule } from '../routers/routers.module';
import { RadiusModule } from '../radius/radius.module';

@Module({
    imports: [PrismaModule, MikroTikModule, RoutersModule, RadiusModule],
    controllers: [VouchersController],
    providers: [VouchersService],
    exports: [VouchersService],
})
export class VouchersModule { }
