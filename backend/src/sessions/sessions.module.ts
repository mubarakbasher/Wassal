import { Module } from '@nestjs/common';
import { SessionsController } from './sessions.controller';
import { SessionsService } from './sessions.service';
import { PrismaService } from '../prisma/prisma.service';
import { RoutersModule } from '../routers/routers.module';

@Module({
    imports: [RoutersModule],
    controllers: [SessionsController],
    providers: [SessionsService, PrismaService],
    exports: [SessionsService],
})
export class SessionsModule { }
