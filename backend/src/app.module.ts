import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ScheduleModule } from '@nestjs/schedule';
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';
import { APP_GUARD } from '@nestjs/core';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { RoutersModule } from './routers/routers.module';
import { VouchersModule } from './vouchers/vouchers.module';
import { ProfilesModule } from './profiles/profiles.module';
import { UsersModule } from './users/users.module';
import { SalesModule } from './sales/sales.module';
import { SessionsModule } from './sessions/sessions.module';
import { NotificationsModule } from './notifications/notifications.module';
import { MonitoringModule } from './monitoring/monitoring.module';
import { AdminModule } from './admin/admin.module';
import { SubscriptionsModule } from './subscriptions/subscriptions.module';
import { RadiusModule } from './radius/radius.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    ScheduleModule.forRoot(),
    ThrottlerModule.forRoot([
      {
        name: 'short',
        ttl: 1000,   // 1 second window
        limit: 10,   // max 10 requests per second
      },
      {
        name: 'medium',
        ttl: 60000,  // 1 minute window
        limit: 100,  // max 100 requests per minute
      },
    ]),
    PrismaModule,
    AuthModule,
    RoutersModule,
    VouchersModule,
    ProfilesModule,
    UsersModule,
    SalesModule,
    SessionsModule,
    NotificationsModule,
    MonitoringModule,
    AdminModule,
    SubscriptionsModule,
    RadiusModule,
  ],
  controllers: [AppController],
  providers: [
    AppService,
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },
  ],
})
export class AppModule { }

