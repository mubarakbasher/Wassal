import { Module } from '@nestjs/common';
import { MikroTikApiService } from './mikrotik-api.service';

@Module({
    providers: [MikroTikApiService],
    exports: [MikroTikApiService],
})
export class MikroTikModule { }
