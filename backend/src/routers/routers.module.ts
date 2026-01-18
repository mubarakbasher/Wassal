import { Module } from '@nestjs/common';
import { RoutersController } from './routers.controller';
import { RoutersService } from './routers.service';
import { MikroTikModule } from '../mikrotik/mikrotik.module';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
    imports: [PrismaModule, MikroTikModule],
    controllers: [RoutersController],
    providers: [RoutersService],
    exports: [RoutersService],
})
export class RoutersModule { }
