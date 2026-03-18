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
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { RoutersService } from './routers.service';
import { CreateRouterDto, UpdateRouterDto } from './dto/router.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { SubscriptionGuard } from '../auth/guards/subscription.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import * as crypto from 'crypto';

@ApiTags('Routers')
@ApiBearerAuth('JWT')
@Controller('routers')
@UseGuards(JwtAuthGuard, SubscriptionGuard)
export class RoutersController {
    constructor(private readonly routersService: RoutersService) { }

    @Post()
    @ApiOperation({ summary: 'Create a new router' })
    create(@CurrentUser() user: any, @Body() createRouterDto: CreateRouterDto) {
        return this.routersService.create(user.id, createRouterDto);
    }

    @Get()
    @ApiOperation({ summary: 'List all routers' })
    findAll(@CurrentUser() user: any, @Query('statusOnly') statusOnly?: string) {
        return this.routersService.findAll(user.id, statusOnly === 'true');
    }

    @Get(':id')
    @ApiOperation({ summary: 'Get a router by ID' })
    findOne(@Param('id') id: string, @CurrentUser() user: any) {
        return this.routersService.findOne(id, user.id);
    }

    @Put(':id')
    @ApiOperation({ summary: 'Update a router' })
    update(
        @Param('id') id: string,
        @CurrentUser() user: any,
        @Body() updateRouterDto: UpdateRouterDto,
    ) {
        return this.routersService.update(id, user.id, updateRouterDto);
    }

    @Delete(':id')
    @HttpCode(HttpStatus.OK)
    @ApiOperation({ summary: 'Delete a router' })
    remove(@Param('id') id: string, @CurrentUser() user: any) {
        return this.routersService.remove(id, user.id);
    }

    @Get(':id/health')
    @ApiOperation({ summary: 'Check router health' })
    checkHealth(@Param('id') id: string, @CurrentUser() user: any) {
        return this.routersService.checkHealth(id, user.id);
    }

    @Get(':id/system-info')
    @ApiOperation({ summary: 'Get router system information' })
    getSystemInfo(@Param('id') id: string, @CurrentUser() user: any) {
        return this.routersService.getSystemInfo(id, user.id);
    }

    @Get(':id/stats')
    @ApiOperation({ summary: 'Get router statistics' })
    getStats(@Param('id') id: string, @CurrentUser() user: any) {
        return this.routersService.getRouterStats(id, user.id);
    }

    @Get(':id/profiles/mikrotik')
    @ApiOperation({ summary: 'Get MikroTik profiles for a router' })
    getMikrotikProfiles(@Param('id') id: string, @CurrentUser() user: any) {
        return this.routersService.getMikrotikProfiles(id, user.id);
    }

    @Post(':id/profiles/mikrotik')
    @ApiOperation({ summary: 'Create a MikroTik profile on a router' })
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
    @ApiOperation({ summary: 'Get active users on a router' })
    getActiveUsers(@Param('id') id: string, @CurrentUser() user: any) {
        return this.routersService.getActiveUsers(id, user.id);
    }

    @Get(':id/interfaces')
    @ApiOperation({ summary: 'Get router network interfaces' })
    getInterfaces(@Param('id') id: string, @CurrentUser() user: any) {
        return this.routersService.getInterfaces(id, user.id);
    }

    @Get(':id/logs')
    @ApiOperation({ summary: 'Get router logs' })
    getLogs(
        @Param('id') id: string,
        @Query('limit') limit: string,
        @CurrentUser() user: any
    ) {
        return this.routersService.getRouterLogs(id, user.id, parseInt(limit) || 50);
    }

    @Post(':id/disconnect-user')
    @ApiOperation({ summary: 'Disconnect an active user from a router' })
    disconnectUser(
        @Param('id') id: string,
        @Body('sessionId') sessionId: string,
        @CurrentUser() user: any
    ) {
        return this.routersService.disconnectUser(id, sessionId, user.id);
    }

    @Post(':id/restart')
    @ApiOperation({ summary: 'Restart a router' })
    restartRouter(@Param('id') id: string, @CurrentUser() user: any) {
        return this.routersService.restartRouter(id, user.id);
    }

    @Post(':id/setup-radius')
    @ApiOperation({ summary: 'Setup RADIUS on a router' })
    setupRadius(@Param('id') id: string, @CurrentUser() user: any) {
        return this.routersService.setupRadius(id, user.id);
    }

    @Get(':id/debug/connectivity')
    @ApiOperation({ summary: 'Debug router connectivity' })
    debugConnectivity(@Param('id') id: string, @CurrentUser() user: any) {
        return this.routersService.debugConnectivity(id, user.id);
    }

    @Post('wireguard-setup')
    @ApiOperation({ summary: 'Generate WireGuard setup configuration' })
    generateWireguardSetup(@CurrentUser() user: any) {
        return this.routersService.generateWireguardSetup(user.id);
    }
}

@ApiTags('Public Routers')
@Controller('public/routers')
export class PublicRoutersController {
    constructor(private readonly routersService: RoutersService) { }

    @Get('script-callback')
    @ApiOperation({ summary: 'Handle router script callback' })
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
