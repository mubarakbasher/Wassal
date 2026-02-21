import { Module } from '@nestjs/common';
import { AdminRoutersController } from './admin-routers.controller';
import { AdminRoutersService } from './admin-routers.service';
import { PrismaModule } from '../../prisma/prisma.module';
import { MikroTikModule } from '../../mikrotik/mikrotik.module';
import { RadiusModule } from '../../radius/radius.module';
import { AdminAuthModule } from '../auth/admin-auth.module';

@Module({
    imports: [PrismaModule, MikroTikModule, RadiusModule, AdminAuthModule],
    controllers: [AdminRoutersController],
    providers: [AdminRoutersService],
    exports: [AdminRoutersService],
})
export class AdminRoutersModule { }
