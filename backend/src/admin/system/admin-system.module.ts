import { Module } from '@nestjs/common';
import { AdminSystemController } from './admin-system.controller';
import { AdminSystemService } from './admin-system.service';
import { PrismaModule } from '../../prisma/prisma.module';

@Module({
    imports: [PrismaModule],
    controllers: [AdminSystemController],
    providers: [AdminSystemService],
})
export class AdminSystemModule { }
