import { Module } from '@nestjs/common';
import { WireGuardService } from './wireguard.service';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
    imports: [PrismaModule],
    providers: [WireGuardService],
    exports: [WireGuardService],
})
export class WireGuardModule {}
