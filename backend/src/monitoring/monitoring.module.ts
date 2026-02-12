import { Module } from '@nestjs/common';
import { RouterMonitorService } from './router-monitor.service';
import { PrismaModule } from '../prisma/prisma.module';
import { MikroTikModule } from '../mikrotik/mikrotik.module';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
    imports: [PrismaModule, MikroTikModule, NotificationsModule],
    providers: [RouterMonitorService],
    exports: [RouterMonitorService],
})
export class MonitoringModule { }
