import { Module } from '@nestjs/common';
import { RadiusService } from './radius.service';
import { RadiusSyncService } from './radius-sync.service';
import { RadiusController } from './radius.controller';
import { PrismaModule } from '../prisma/prisma.module';
import { MikroTikModule } from '../mikrotik/mikrotik.module';

@Module({
    imports: [PrismaModule, MikroTikModule],
    controllers: [RadiusController],
    providers: [RadiusService, RadiusSyncService],
    exports: [RadiusService],
})
export class RadiusModule { }

