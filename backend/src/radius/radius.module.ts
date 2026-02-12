import { Module } from '@nestjs/common';
import { RadiusService } from './radius.service';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
    imports: [PrismaModule],
    providers: [RadiusService],
    exports: [RadiusService],
})
export class RadiusModule {}
