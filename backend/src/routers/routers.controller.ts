import {
    Controller,
    Get,
    Post,
    Put,
    Delete,
    Body,
    Param,
    UseGuards,
    HttpCode,
    HttpStatus,
    Query,
    Req,
    BadRequestException,
} from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import { RoutersService } from './routers.service';
import { CreateRouterDto, UpdateRouterDto } from './dto/router.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { SubscriptionGuard } from '../auth/guards/subscription.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import * as crypto from 'crypto';

@Controller('routers')
@UseGuards(JwtAuthGuard, SubscriptionGuard)
export class RoutersController {
    constructor(private readonly routersService: RoutersService) { }

    @Post()
    create(@CurrentUser() user: any, @Body() createRouterDto: CreateRouterDto) {
        return this.routersService.create(user.id, createRouterDto);
    }

    @Get()
    findAll(@CurrentUser() user: any, @Query('statusOnly') statusOnly?: string) {
        return this.routersService.findAll(user.id, statusOnly === 'true');
    }

    @Get(':id')
    findOne(@Param('id') id: string, @CurrentUser() user: any) {
        return this.routersService.findOne(id, user.id);
    }

    @Put(':id')
    update(
        @Param('id') id: string,
        @CurrentUser() user: any,
        @Body() updateRouterDto: UpdateRouterDto,
    ) {
        return this.routersService.update(id, user.id, updateRouterDto);
    }

    @Delete(':id')
    @HttpCode(HttpStatus.OK)
    remove(@Param('id') id: string, @CurrentUser() user: any) {
        return this.routersService.remove(id, user.id);
    }

    @Get(':id/health')
    checkHealth(@Param('id') id: string, @CurrentUser() user: any) {
        return this.routersService.checkHealth(id, user.id);
    }

    @Get(':id/system-info')
    getSystemInfo(@Param('id') id: string, @CurrentUser() user: any) {
        return this.routersService.getSystemInfo(id, user.id);
    }

    @Get(':id/stats')
    getStats(@Param('id') id: string, @CurrentUser() user: any) {
        return this.routersService.getRouterStats(id, user.id);
    }

    @Get(':id/profiles/mikrotik')
    getMikrotikProfiles(@Param('id') id: string, @CurrentUser() user: any) {
        return this.routersService.getMikrotikProfiles(id, user.id);
    }

    @Post(':id/profiles/mikrotik')
    createMikrotikProfile(
        @Param('id') id: string,
        @Body() profileData: {
            name: string;
            rateLimit?: string;
            sessionTimeout?: string;
            limitUptime?: string;
            sharedUsers?: number;
            idleTimeout?: string;
            keepaliveTimeout?: string;
            useSchedulerTime?: boolean;
            schedulerInterval?: string;
        },
        @CurrentUser() user: any
    ) {
        return this.routersService.createMikrotikProfile(id, user.id, profileData);
    }

    @Get(':id/active-users')
    getActiveUsers(@Param('id') id: string, @CurrentUser() user: any) {
        return this.routersService.getActiveUsers(id, user.id);
    }

    @Get(':id/interfaces')
    getInterfaces(@Param('id') id: string, @CurrentUser() user: any) {
        return this.routersService.getInterfaces(id, user.id);
    }

    @Get(':id/logs')
    getLogs(
        @Param('id') id: string,
        @Query('limit') limit: string,
        @CurrentUser() user: any
    ) {
        return this.routersService.getRouterLogs(id, user.id, parseInt(limit) || 50);
    }

    @Post(':id/disconnect-user')
    disconnectUser(
        @Param('id') id: string,
        @Body('sessionId') sessionId: string,
        @CurrentUser() user: any
    ) {
        return this.routersService.disconnectUser(id, sessionId, user.id);
    }

    @Post(':id/restart')
    restartRouter(@Param('id') id: string, @CurrentUser() user: any) {
        return this.routersService.restartRouter(id, user.id);
    }

    @Post(':id/setup-radius')
    setupRadius(@Param('id') id: string, @CurrentUser() user: any) {
        return this.routersService.setupRadius(id, user.id);
    }

    @Get(':id/debug/connectivity')
    debugConnectivity(@Param('id') id: string, @CurrentUser() user: any) {
        return this.routersService.debugConnectivity(id, user.id);
    }

    @Post('wireguard-setup')
    generateWireguardSetup(@CurrentUser() user: any) {
        return this.routersService.generateWireguardSetup(user.id);
    }
}

@Controller('public/routers')
export class PublicRoutersController {
    constructor(private readonly routersService: RoutersService) { }

    @Get('script-callback')
    @Throttle({ short: { limit: 3, ttl: 60000 } })
    handleCallback(
        @Query('ip') ip: string,
        @Query('vpnIp') vpnIp: string,
        @Query('userId') userId: string,
        @Query('sig') sig: string,
        @Req() req: any
    ) {
        if (!userId) {
            throw new BadRequestException('Missing userId parameter');
        }

        const secret = process.env.JWT_SECRET!;
        if (secret) {
            if (!sig) {
                throw new BadRequestException('Missing callback signature');
            }
            const expectedSig = crypto
                .createHmac('sha256', secret)
                .update(userId)
                .digest('hex')
                .substring(0, 16);
            if (sig !== expectedSig) {
                throw new BadRequestException('Invalid callback signature');
            }
        }
        // WireGuard VPN path: vpnIp is provided by the script
        if (vpnIp) {
            return this.routersService.handleScriptCallback(vpnIp, userId, vpnIp);
        }

        // Legacy path: detect IP from request
        const forwardedFor = req.headers['x-forwarded-for'];
        const realIp = req.headers['x-real-ip'];
        const socketIp = req.ip || req.connection?.remoteAddress;

        let requestIp = ip;

        if (!requestIp && forwardedFor) {
            requestIp = forwardedFor.split(',')[0].trim();
        }

        if (!requestIp && realIp) {
            requestIp = realIp;
        }

        if (!requestIp) {
            requestIp = socketIp;
        }

        const cleanIp = requestIp?.replace('::ffff:', '') || '';

        if (!cleanIp || cleanIp === '127.0.0.1' || cleanIp === '::1') {
            return {
                message: 'Invalid IP address. Cannot register router from localhost.',
                error: 'IP detection failed. Make sure to run the script from MikroTik terminal.'
            };
        }

        return this.routersService.handleScriptCallback(cleanIp, userId);
    }
}
