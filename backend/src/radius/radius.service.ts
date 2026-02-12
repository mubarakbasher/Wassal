import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

/**
 * RadiusService manages FreeRADIUS database tables.
 * 
 * Instead of creating hotspot users directly on MikroTik,
 * we write user credentials and attributes to the RADIUS
 * database. FreeRADIUS reads these tables to authenticate
 * hotspot users and return access rules to MikroTik.
 */
@Injectable()
export class RadiusService {
    private readonly logger = new Logger(RadiusService.name);

    constructor(private prisma: PrismaService) { }

    // ==========================================
    // USER MANAGEMENT
    // ==========================================

    /**
     * Create a RADIUS user with password and assign to a group.
     * This replaces the old createHotspotUser on MikroTik.
     */
    async createRadiusUser(
        username: string,
        password: string,
        groupName: string,
    ): Promise<void> {
        // Insert password into radcheck
        await this.prisma.radCheck.create({
            data: {
                username,
                attribute: 'Cleartext-Password',
                op: ':=',
                value: password,
            },
        });

        // Assign user to group (for group-level attributes like speed)
        await this.prisma.radUserGroup.create({
            data: {
                username,
                groupname: groupName,
                priority: 1,
            },
        });

        this.logger.log(`Created RADIUS user: ${username} in group: ${groupName}`);
    }

    /**
     * Remove a RADIUS user and all associated data.
     */
    async removeRadiusUser(username: string): Promise<void> {
        // Delete in parallel — all tables referencing this username
        await Promise.all([
            this.prisma.radCheck.deleteMany({ where: { username } }),
            this.prisma.radReply.deleteMany({ where: { username } }),
            this.prisma.radUserGroup.deleteMany({ where: { username } }),
        ]);

        this.logger.log(`Removed RADIUS user: ${username}`);
    }

    /**
     * Check if a RADIUS user exists.
     */
    async userExists(username: string): Promise<boolean> {
        const count = await this.prisma.radCheck.count({
            where: { username, attribute: 'Cleartext-Password' },
        });
        return count > 0;
    }

    // ==========================================
    // CHECK ATTRIBUTES (radcheck)
    // ==========================================

    /**
     * Set the Expiration attribute for real-time countdown.
     * After this date/time, FreeRADIUS will reject logins.
     * 
     * Format: "February 11 2026 01:00:00" (FreeRADIUS date format)
     */
    async setExpiration(username: string, expiresAt: Date): Promise<void> {
        const expirationStr = this.formatRadiusDate(expiresAt);

        // Upsert: update if exists, create if not
        const existing = await this.prisma.radCheck.findFirst({
            where: { username, attribute: 'Expiration' },
        });

        if (existing) {
            await this.prisma.radCheck.update({
                where: { id: existing.id },
                data: { value: expirationStr },
            });
        } else {
            await this.prisma.radCheck.create({
                data: {
                    username,
                    attribute: 'Expiration',
                    op: ':=',
                    value: expirationStr,
                },
            });
        }

        this.logger.debug(`Set Expiration for ${username}: ${expirationStr}`);
    }

    /**
     * Get the Expiration attribute for a user.
     */
    async getExpiration(username: string): Promise<Date | null> {
        const record = await this.prisma.radCheck.findFirst({
            where: { username, attribute: 'Expiration' },
        });

        if (!record) return null;

        return new Date(record.value);
    }

    // ==========================================
    // REPLY ATTRIBUTES (radreply) — per-user
    // ==========================================

    /**
     * Set a reply attribute for a specific user.
     * Reply attributes are sent back to MikroTik on Access-Accept.
     */
    async setUserReplyAttribute(
        username: string,
        attribute: string,
        value: string,
        op: string = '=',
    ): Promise<void> {
        const existing = await this.prisma.radReply.findFirst({
            where: { username, attribute },
        });

        if (existing) {
            await this.prisma.radReply.update({
                where: { id: existing.id },
                data: { value, op },
            });
        } else {
            await this.prisma.radReply.create({
                data: { username, attribute, op, value },
            });
        }
    }

    /**
     * Set Mikrotik-Rate-Limit for a specific user.
     * Format: "rx-rate[/tx-rate]" e.g. "2M/2M"
     */
    async setUserRateLimit(username: string, rateLimit: string): Promise<void> {
        await this.setUserReplyAttribute(username, 'Mikrotik-Rate-Limit', rateLimit);
    }

    /**
     * Set Session-Timeout for a user (remaining seconds).
     * This is recalculated from Expiration on each login by FreeRADIUS.
     */
    async setSessionTimeout(username: string, seconds: number): Promise<void> {
        await this.setUserReplyAttribute(username, 'Session-Timeout', seconds.toString());
    }

    /**
     * Set Simultaneous-Use for a specific user (max devices).
     */
    async setUserSimultaneousUse(username: string, limit: number): Promise<void> {
        // Simultaneous-Use is a CHECK attribute, not reply
        const existing = await this.prisma.radCheck.findFirst({
            where: { username, attribute: 'Simultaneous-Use' },
        });

        if (existing) {
            await this.prisma.radCheck.update({
                where: { id: existing.id },
                data: { value: limit.toString() },
            });
        } else {
            await this.prisma.radCheck.create({
                data: {
                    username,
                    attribute: 'Simultaneous-Use',
                    op: ':=',
                    value: limit.toString(),
                },
            });
        }
    }

    // ==========================================
    // GROUP MANAGEMENT (profiles → groups)
    // ==========================================

    /**
     * Create or update a RADIUS group with reply attributes.
     * Maps to HotspotProfile — group-level speed/device limits.
     */
    async upsertGroup(
        groupName: string,
        attributes: { rateLimit?: string; sharedUsers?: number },
    ): Promise<void> {
        // Set Mikrotik-Rate-Limit for the group
        if (attributes.rateLimit) {
            await this.upsertGroupReplyAttribute(groupName, 'Mikrotik-Rate-Limit', attributes.rateLimit);
        }

        // Set Simultaneous-Use for the group (max devices)
        if (attributes.sharedUsers !== undefined) {
            await this.upsertGroupCheckAttribute(groupName, 'Simultaneous-Use', attributes.sharedUsers.toString());
        }

        this.logger.log(`Upserted RADIUS group: ${groupName}`);
    }

    /**
     * Remove a RADIUS group and all its attributes.
     */
    async removeGroup(groupName: string): Promise<void> {
        await Promise.all([
            this.prisma.radGroupCheck.deleteMany({ where: { groupname: groupName } }),
            this.prisma.radGroupReply.deleteMany({ where: { groupname: groupName } }),
            this.prisma.radUserGroup.deleteMany({ where: { groupname: groupName } }),
        ]);

        this.logger.log(`Removed RADIUS group: ${groupName}`);
    }

    /**
     * Upsert a group reply attribute.
     */
    private async upsertGroupReplyAttribute(
        groupName: string,
        attribute: string,
        value: string,
        op: string = '=',
    ): Promise<void> {
        const existing = await this.prisma.radGroupReply.findFirst({
            where: { groupname: groupName, attribute },
        });

        if (existing) {
            await this.prisma.radGroupReply.update({
                where: { id: existing.id },
                data: { value, op },
            });
        } else {
            await this.prisma.radGroupReply.create({
                data: { groupname: groupName, attribute, op, value },
            });
        }
    }

    /**
     * Upsert a group check attribute.
     */
    private async upsertGroupCheckAttribute(
        groupName: string,
        attribute: string,
        value: string,
        op: string = ':=',
    ): Promise<void> {
        const existing = await this.prisma.radGroupCheck.findFirst({
            where: { groupname: groupName, attribute },
        });

        if (existing) {
            await this.prisma.radGroupCheck.update({
                where: { id: existing.id },
                data: { value, op },
            });
        } else {
            await this.prisma.radGroupCheck.create({
                data: { groupname: groupName, attribute, op, value },
            });
        }
    }

    // ==========================================
    // NAS MANAGEMENT (MikroTik routers)
    // ==========================================

    /**
     * Register a MikroTik router as a NAS client.
     * FreeRADIUS checks the nas table to verify incoming requests.
     */
    async registerNas(
        nasIp: string,
        secret: string,
        shortname?: string,
        description?: string,
    ): Promise<void> {
        // Check if already registered
        const existing = await this.prisma.nas.findFirst({
            where: { nasname: nasIp },
        });

        if (existing) {
            await this.prisma.nas.update({
                where: { id: existing.id },
                data: {
                    secret,
                    shortname: shortname || existing.shortname,
                    description: description || existing.description,
                    type: 'other',
                },
            });
            this.logger.log(`Updated NAS: ${nasIp}`);
        } else {
            await this.prisma.nas.create({
                data: {
                    nasname: nasIp,
                    shortname: shortname || nasIp,
                    type: 'other',
                    secret,
                    description,
                },
            });
            this.logger.log(`Registered NAS: ${nasIp} (${shortname})`);
        }
    }

    /**
     * Remove a NAS client.
     */
    async removeNas(nasIp: string): Promise<void> {
        await this.prisma.nas.deleteMany({
            where: { nasname: nasIp },
        });
        this.logger.log(`Removed NAS: ${nasIp}`);
    }

    // ==========================================
    // ACCOUNTING (radacct) — read-only queries
    // ==========================================

    /**
     * Get total session time for a user (from accounting data).
     * Returns total seconds the user has been connected across all sessions.
     */
    async getTotalSessionTime(username: string): Promise<number> {
        const result = await this.prisma.radAcct.aggregate({
            where: { username },
            _sum: { acctsessiontime: true },
        });

        return result._sum.acctsessiontime || 0;
    }

    /**
     * Get total bytes transferred for a user.
     */
    async getTotalBytes(username: string): Promise<{ bytesIn: bigint; bytesOut: bigint }> {
        const result = await this.prisma.radAcct.aggregate({
            where: { username },
            _sum: {
                acctinputoctets: true,
                acctoutputoctets: true,
            },
        });

        return {
            bytesIn: result._sum.acctinputoctets || BigInt(0),
            bytesOut: result._sum.acctoutputoctets || BigInt(0),
        };
    }

    /**
     * Get active sessions for a user.
     */
    async getActiveSessions(username: string): Promise<any[]> {
        return this.prisma.radAcct.findMany({
            where: {
                username,
                acctstoptime: null, // No stop time = still active
            },
            orderBy: { acctstarttime: 'desc' },
        });
    }

    /**
     * Get all session history for a user.
     */
    async getSessionHistory(username: string, limit: number = 50): Promise<any[]> {
        return this.prisma.radAcct.findMany({
            where: { username },
            orderBy: { acctstarttime: 'desc' },
            take: limit,
        });
    }

    // ==========================================
    // HELPERS
    // ==========================================

    /**
     * Format a Date as a FreeRADIUS-compatible string.
     * FreeRADIUS expects: "Month Day Year HH:MM:SS"
     * Example: "February 11 2026 01:00:00"
     */
    private formatRadiusDate(date: Date): string {
        const months = [
            'January', 'February', 'March', 'April', 'May', 'June',
            'July', 'August', 'September', 'October', 'November', 'December',
        ];

        const month = months[date.getMonth()];
        const day = date.getDate();
        const year = date.getFullYear();
        const hours = date.getHours().toString().padStart(2, '0');
        const minutes = date.getMinutes().toString().padStart(2, '0');
        const seconds = date.getSeconds().toString().padStart(2, '0');

        return `${month} ${day} ${year} ${hours}:${minutes}:${seconds}`;
    }

    /**
     * Calculate remaining seconds until expiration.
     * Used to set Session-Timeout reply attribute.
     */
    calculateRemainingSeconds(expiresAt: Date): number {
        const now = new Date();
        const diff = expiresAt.getTime() - now.getTime();
        return Math.max(0, Math.floor(diff / 1000));
    }
}
