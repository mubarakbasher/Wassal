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
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Session } from '@prisma/client';

@Controller('sessions')
@UseGuards(JwtAuthGuard, SubscriptionGuard)
export class SessionsController {
    constructor(private readonly sessionsService: SessionsService) { }

    @Get()
    async findAll(@CurrentUser() user: any, @Query('active') active?: string): Promise<Session[]> {
        const isActive = active === 'true' ? true : active === 'false' ? false : undefined;
        return this.sessionsService.findAll(user.id, isActive);
    }

    @Get('active')
    async findActive(@CurrentUser() user: any): Promise<Session[]> {
        return this.sessionsService.findAll(user.id, true);
    }

    @Get('router/:routerId')
    async findByRouter(
        @CurrentUser() user: any,
        @Param('routerId') routerId: string,
        @Query('active') active?: string,
    ): Promise<Session[]> {
        const isActive = active === 'true' ? true : active === 'false' ? false : undefined;
        return this.sessionsService.findByRouter(user.id, routerId, isActive);
    }

    @Get('stats')
    async getGlobalStatistics(@CurrentUser() user: any) {
        return this.sessionsService.getStatistics(user.id);
    }

    @Get('stats/:routerId')
    async getStatistics(@CurrentUser() user: any, @Param('routerId') routerId: string) {
        return this.sessionsService.getStatistics(user.id, routerId);
    }

    @Get(':id')
    async findOne(@CurrentUser() user: any, @Param('id') id: string): Promise<Session> {
        return this.sessionsService.findOne(user.id, id);
    }

    @Delete(':id')
    @HttpCode(HttpStatus.OK)
    async terminate(@CurrentUser() user: any, @Param('id') id: string): Promise<{ message: string; session: Session }> {
        const session = await this.sessionsService.terminateSession(user.id, id);
        return {
            message: 'Session terminated successfully',
            session,
        };
    }
}
