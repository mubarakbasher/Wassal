import { Module } from '@nestjs/common';
import { AdminAuthModule } from './auth/admin-auth.module';
import { AdminUsersModule } from './users/admin-users.module';
import { AdminSubscriptionsModule } from './subscriptions/admin-subscriptions.module';
import { AdminSystemModule } from './system/admin-system.module';
import { AdminPaymentsModule } from './payments/admin-payments.module';

@Module({
    imports: [
        AdminAuthModule,
        AdminUsersModule,
        AdminSubscriptionsModule,
        AdminSystemModule,
        AdminPaymentsModule,
    ],
})
export class AdminModule { }
