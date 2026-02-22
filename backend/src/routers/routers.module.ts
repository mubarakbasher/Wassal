import { Module } from '@nestjs/common';
import { RoutersController, PublicRoutersController } from './routers.controller';
import { RoutersService } from './routers.service';
import { MikroTikModule } from '../mikrotik/mikrotik.module';
import { PrismaModule } from '../prisma/prisma.module';
import { RadiusModule } from '../radius/radius.module';
import { WireGuardModule } from '../wireguard/wireguard.module';

@Module({
    imports: [PrismaModule, MikroTikModule, RadiusModule, WireGuardModule],
    controllers: [RoutersController, PublicRoutersController],
    providers: [RoutersService],
    exports: [RoutersService],
})
export class RoutersModule { }
