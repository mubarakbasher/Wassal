import {
    Controller,
    Get,
    Param,
    Query,
    UseGuards,
} from '@nestjs/common';
import { RadiusService } from './radius.service';
import { AdminJwtAuthGuard } from '../admin/auth/guards/admin-jwt-auth.guard';
import { PrismaService } from '../prisma/prisma.service';

@Controller('radius')
@UseGuards(AdminJwtAuthGuard)
export class RadiusController {
    constructor(
        private readonly radiusService: RadiusService,
        private readonly prisma: PrismaService,
    ) { }

    /**
     * RADIUS status — table counts and health check
     */
    @Get('status')
    async getStatus() {
        const [
            userCount,
            groupCount,
            nasCount,
            activeSessionCount,
            postAuthCount,
        ] = await Promise.all([
            this.prisma.radCheck.count({
                where: { attribute: 'Cleartext-Password' },
            }),
            this.prisma.radGroupReply.count(),
            this.prisma.nas.count(),
            this.prisma.radAcct.count({
                where: { acctstoptime: null },
            }),
            this.prisma.radPostAuth.count(),
        ]);

        return {
            status: 'ok',
            tables: {
                users: userCount,
                groups: groupCount,
                nasClients: nasCount,
                activeSessions: activeSessionCount,
                authLogs: postAuthCount,
            },
        };
    }

    /**
     * List all RADIUS users (from radcheck)
     */
    @Get('users')
    async getUsers(
        @Query('page') page: string = '1',
        @Query('limit') limit: string = '50',
    ) {
        const pageNum = Math.max(1, parseInt(page) || 1);
        const limitNum = Math.min(100, Math.max(1, parseInt(limit) || 50));
        const skip = (pageNum - 1) * limitNum;

        // Get unique usernames from radcheck
        const users = await this.prisma.radCheck.findMany({
            where: { attribute: 'Cleartext-Password' },
            select: { username: true, value: true },
            skip,
            take: limitNum,
            orderBy: { id: 'desc' },
        });

        const total = await this.prisma.radCheck.count({
            where: { attribute: 'Cleartext-Password' },
        });

        // Enrich with group info
        const enriched = await Promise.all(
            users.map(async (user) => {
                const groups = await this.prisma.radUserGroup.findMany({
                    where: { username: user.username },
                    select: { groupname: true, priority: true },
                });

                const replyAttrs = await this.prisma.radReply.findMany({
                    where: { username: user.username },
                    select: { attribute: true, value: true, op: true },
                });

                const checkAttrs = await this.prisma.radCheck.findMany({
                    where: {
                        username: user.username,
                        attribute: { not: 'Cleartext-Password' },
                    },
                    select: { attribute: true, value: true, op: true },
                });

                return {
                    username: user.username,
                    groups: groups.map((g) => g.groupname),
                    checkAttributes: checkAttrs,
                    replyAttributes: replyAttrs,
                };
            }),
        );

        return {
            data: enriched,
            total,
            page: pageNum,
            limit: limitNum,
            pages: Math.ceil(total / limitNum),
        };
    }

    /**
     * Get a specific RADIUS user's details
     */
    @Get('users/:username')
    async getUser(@Param('username') username: string) {
        const exists = await this.radiusService.userExists(username);
        if (!exists) {
            return { error: 'User not found', username };
        }

        const [checkAttrs, replyAttrs, groups, activeSessions, expiration] =
            await Promise.all([
                this.prisma.radCheck.findMany({
                    where: { username },
                    select: { attribute: true, value: true, op: true },
                }),
                this.prisma.radReply.findMany({
                    where: { username },
                    select: { attribute: true, value: true, op: true },
                }),
                this.prisma.radUserGroup.findMany({
                    where: { username },
                    select: { groupname: true, priority: true },
                }),
                this.radiusService.getActiveSessions(username),
                this.radiusService.getExpiration(username),
            ]);

        const totalBytes = await this.radiusService.getTotalBytes(username);
        const totalTime = await this.radiusService.getTotalSessionTime(username);

        return {
            username,
            checkAttributes: checkAttrs,
            replyAttributes: replyAttrs,
            groups: groups.map((g) => g.groupname),
            expiration,
            activeSessions: activeSessions.length,
            totalSessionTime: totalTime,
            totalBytesIn: totalBytes.bytesIn.toString(),
            totalBytesOut: totalBytes.bytesOut.toString(),
        };
    }

    /**
     * Get currently online users (active radacct sessions)
     */
    @Get('online')
    async getOnlineUsers(
        @Query('page') page: string = '1',
        @Query('limit') limit: string = '50',
    ) {
        const pageNum = Math.max(1, parseInt(page) || 1);
        const limitNum = Math.min(100, Math.max(1, parseInt(limit) || 50));
        const skip = (pageNum - 1) * limitNum;

        const [sessions, total] = await Promise.all([
            this.prisma.radAcct.findMany({
                where: { acctstoptime: null },
                orderBy: { acctstarttime: 'desc' },
                skip,
                take: limitNum,
                select: {
                    radacctid: true,
                    username: true,
                    nasipaddress: true,
                    framedipaddress: true,
                    callingstationid: true,
                    acctstarttime: true,
                    acctsessiontime: true,
                    acctinputoctets: true,
                    acctoutputoctets: true,
                    acctsessionid: true,
                },
            }),
            this.prisma.radAcct.count({
                where: { acctstoptime: null },
            }),
        ]);

        return {
            data: sessions.map((s) => ({
                ...s,
                radacctid: s.radacctid.toString(),
                acctinputoctets: s.acctinputoctets?.toString() || '0',
                acctoutputoctets: s.acctoutputoctets?.toString() || '0',
            })),
            total,
            page: pageNum,
            limit: limitNum,
            pages: Math.ceil(total / limitNum),
        };
    }

    /**
     * Get session history for a specific user
     */
    @Get('accounting/:username')
    async getAccountingHistory(
        @Param('username') username: string,
        @Query('limit') limit: string = '50',
    ) {
        const limitNum = Math.min(100, Math.max(1, parseInt(limit) || 50));

        const sessions = await this.radiusService.getSessionHistory(
            username,
            limitNum,
        );

        return {
            username,
            sessions: sessions.map((s) => ({
                ...s,
                radacctid: s.radacctid.toString(),
                acctinputoctets: s.acctinputoctets?.toString() || '0',
                acctoutputoctets: s.acctoutputoctets?.toString() || '0',
            })),
        };
    }

    /**
     * List all registered NAS clients
     */
    @Get('nas')
    async getNasClients() {
        const clients = await this.prisma.nas.findMany({
            orderBy: { id: 'desc' },
            select: {
                id: true,
                nasname: true,
                shortname: true,
                type: true,
                description: true,
            },
        });

        return { data: clients };
    }
}
