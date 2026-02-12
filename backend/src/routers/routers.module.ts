import { Module } from '@nestjs/common';
import { RoutersController, PublicRoutersController } from './routers.controller';
import { RoutersService } from './routers.service';
import { MikroTikModule } from '../mikrotik/mikrotik.module';
import { PrismaModule } from '../prisma/prisma.module';
import { RadiusModule } from '../radius/radius.module';

@Module({
    imports: [PrismaModule, MikroTikModule, RadiusModule],
    controllers: [RoutersController, PublicRoutersController],
    providers: [RoutersService],
    exports: [RoutersService],
})
export class RoutersModule { }
