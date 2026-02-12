import {
    Controller,
    Get,
    Delete,
    Param,
    Query,
    UseGuards,
    HttpCode,
    HttpStatus,
} from '@nestjs/common';
import { SessionsService } from './sessions.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { SubscriptionGuard } from '../auth/guards/subscription.guard';
import { Session } from '@prisma/client';

@Controller('sessions')
@UseGuards(JwtAuthGuard, SubscriptionGuard)
export class SessionsController {
    constructor(private readonly sessionsService: SessionsService) { }

    @Get()
    async findAll(@Query('active') active?: string): Promise<Session[]> {
        const isActive = active === 'true' ? true : active === 'false' ? false : undefined;
        return this.sessionsService.findAll(isActive);
    }

    @Get('active')
    async findActive(): Promise<Session[]> {
        return this.sessionsService.findAll(true);
    }

    @Get('router/:routerId')
    async findByRouter(
        @Param('routerId') routerId: string,
        @Query('active') active?: string,
    ): Promise<Session[]> {
        const isActive = active === 'true' ? true : active === 'false' ? false : undefined;
        return this.sessionsService.findByRouter(routerId, isActive);
    }

    @Get('stats')
    async getGlobalStatistics() {
        return this.sessionsService.getStatistics();
    }

    @Get('stats/:routerId')
    async getStatistics(@Param('routerId') routerId: string) {
        return this.sessionsService.getStatistics(routerId);
    }

    @Get(':id')
    async findOne(@Param('id') id: string): Promise<Session> {
        return this.sessionsService.findOne(id);
    }

    @Delete(':id')
    @HttpCode(HttpStatus.OK)
    async terminate(@Param('id') id: string): Promise<{ message: string; session: Session }> {
        const session = await this.sessionsService.terminateSession(id);
        return {
            message: 'Session terminated successfully',
            session,
        };
    }
}
