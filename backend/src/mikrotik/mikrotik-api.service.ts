import { Injectable, Logger, InternalServerErrorException } from '@nestjs/common';
const RouterOSAPI = require('node-routeros').RouterOSAPI;

export interface MikroTikConnection {
    host: string;
    port: number;
    username: string;
    password: string;
}

export interface MikroTikCommandResult {
    success: boolean;
    data?: any;
    error?: string;
}

@Injectable()
export class MikroTikApiService {
    private readonly logger = new Logger(MikroTikApiService.name);

    /**
     * Test connection to a MikroTik router
     */
    async testConnection(connection: MikroTikConnection): Promise<boolean> {
        const api = new RouterOSAPI({
            host: connection.host,
            user: connection.username,
            password: connection.password,
            port: connection.port,
            timeout: 15,
        });

        try {
            await api.connect();
            this.logger.log(`Successfully connected to ${connection.host}`);

            // Test with a simple command
            const identity = await api.write('/system/identity/print');

            await api.close();
            return true;
        } catch (error) {
            this.logger.error(`Failed to connect to ${connection.host}: ${error.message}`);
            try {
                await api.close();
            } catch (e) {
                // Ignore close errors
            }
            return false;
        }
    }

    /**
     * Quick connection test with short timeout - used for status checks
     * Returns quickly if router is offline
     */
    async quickTestConnection(connection: MikroTikConnection): Promise<boolean> {
        const api = new RouterOSAPI({
            host: connection.host,
            user: connection.username,
            password: connection.password,
            port: connection.port,
            timeout: 10, // 10 second timeout for reliable status check
        });

        try {
            await api.connect();
            await api.close();
            return true;
        } catch (error) {
            try {
                await api.close();
            } catch (e) {
                // Ignore close errors
            }
            return false;
        }
    }

    /**
     * Execute a command on MikroTik router
     */
    async executeCommand(
        connection: MikroTikConnection,
        command: string,
        params?: any[],
    ): Promise<MikroTikCommandResult> {
        const api = new RouterOSAPI({
            host: connection.host,
            user: connection.username,
            password: connection.password,
            port: connection.port,
            timeout: 20, // Increased timeout for slower routers
        });

        try {
            await api.connect();

            // Write command with parameters
            let response;
            if (params && params.length > 0) {
                response = await api.write(command, params);
            } else {
                response = await api.write(command);
            }

            await api.close();

            return {
                success: true,
                data: response || [],
            };
        } catch (error) {
            // Handle known edge cases that shouldn't crash the server
            const errorMessage = error.message || '';
            const errorErrno = error.errno || '';

            // Handle !empty replies (no data returned) - this is not really an error
            if (errorErrno === 'UNKNOWNREPLY' || errorMessage.includes('!empty') || errorMessage.includes('unknown reply')) {
                this.logger.debug(`Command ${command} returned empty/unknown reply - treating as empty result`);
                try {
                    await api.close();
                } catch (e) {
                    // Ignore close errors
                }
                return {
                    success: true,
                    data: [],
                };
            }

            this.logger.error(`Command execution failed on ${connection.host}: ${error.message}`);
            try {
                await api.close();
            } catch (e) {
                // Ignore close errors
            }

            return {
                success: false,
                error: error.message,
            };
        }
    }

    /**
     * Get router system information
     */
    async getSystemInfo(connection: MikroTikConnection): Promise<any> {
        const result = await this.executeCommand(connection, '/system/resource/print');

        if (!result.success) {
            this.logger.warn(`Failed to get system information: ${result.error}`);
            return [];
        }

        return result.data;
    }

    /**
     * Get router identity
     */
    async getIdentity(connection: MikroTikConnection): Promise<string> {
        const result = await this.executeCommand(connection, '/system/identity/print');

        if (!result.success || !result.data || result.data.length === 0) {
            throw new InternalServerErrorException('Failed to get router identity');
        }

        return result.data[0].name || 'Unknown';
    }

    /**
     * Get router uptime
     */
    async getUptime(connection: MikroTikConnection): Promise<string> {
        const result = await this.executeCommand(connection, '/system/resource/print');

        if (!result.success || !result.data || result.data.length === 0) {
            this.logger.warn(`Failed to get router uptime: ${result.error}`);
            return '0s';
        }

        return result.data[0].uptime || '0s';
    }

    /**
     * Create hotspot user
     */
    async createHotspotUser(
        connection: MikroTikConnection,
        username: string,
        password: string,
        profile: string,
        timeLimit?: string,
        dataLimit?: number,
    ): Promise<MikroTikCommandResult> {
        const params = [
            `=name=${username}`,
            `=password=${password}`,
            `=profile=${profile}`,
        ];

        if (timeLimit) {
            // Set limit-uptime directly on the hotspot user
            // MikroTik enforces this natively (uptime-based: counts only while connected)
            params.push(`=limit-uptime=${timeLimit}`);
            // Also store in comment for reference
            params.push(`=comment=${timeLimit}`);
        }

        if (dataLimit) {
            // Explicitly convert to string
            params.push(`=limit-bytes-total=${dataLimit.toString()}`);
        }

        this.logger.debug(`Creating Hotspot User: /ip/hotspot/user/add with params: ${JSON.stringify(params)}`);

        return this.executeCommand(connection, '/ip/hotspot/user/add', params);
    }

    /**
     * Remove hotspot user
     */
    async removeHotspotUser(
        connection: MikroTikConnection,
        username: string,
    ): Promise<MikroTikCommandResult> {
        // First, find the user ID
        const findResult = await this.executeCommand(
            connection,
            '/ip/hotspot/user/print',
            [`?name=${username}`],
        );

        if (!findResult.success || !findResult.data || findResult.data.length === 0) {
            return {
                success: false,
                error: 'User not found',
            };
        }

        const userId = findResult.data[0]['.id'];

        // Remove the user
        return this.executeCommand(connection, '/ip/hotspot/user/remove', [
            `=.id=${userId}`,
        ]);
    }

    /**
     * Get active hotspot sessions
     */
    async getActiveSessions(connection: MikroTikConnection): Promise<any[]> {
        const result = await this.executeCommand(connection, '/ip/hotspot/active/print');

        if (!result.success) {
            this.logger.warn(`Failed to get active sessions: ${result.error}`);
            return [];
        }

        return result.data || [];
    }

    /**
     * Disconnect a hotspot user
     */
    async disconnectUser(
        connection: MikroTikConnection,
        sessionId: string,
    ): Promise<MikroTikCommandResult> {
        return this.executeCommand(connection, '/ip/hotspot/active/remove', [
            `=.id=${sessionId}`,
        ]);
    }

    /**
     * Get hotspot profiles
     */
    async getHotspotProfiles(connection: MikroTikConnection): Promise<any[]> {
        const result = await this.executeCommand(connection, '/ip/hotspot/user/profile/print');

        if (!result.success) {
            this.logger.warn(`Failed to get hotspot profiles: ${result.error}`);
            return [];
        }

        return result.data || [];
    }

    /**
     * Create a new hotspot profile
     * Supports scheduler-based time control via on-login script
     */
    async createHotspotProfile(
        connection: MikroTikConnection,
        profile: {
            name: string;
            rateLimit?: string;
            sessionTimeout?: string;
            limitUptime?: string;
            sharedUsers?: number;
            idleTimeout?: string;
            keepaliveTimeout?: string;
            onLoginScript?: string;
            useSchedulerTime?: boolean;
            schedulerInterval?: string; // e.g., "1d", "1h", "30m"
        }
    ): Promise<{ success: boolean; error?: string }> {
        const params: string[] = [`=name=${profile.name}`];

        if (profile.rateLimit) {
            params.push(`=rate-limit=${profile.rateLimit}`);
        }

        // If using scheduler-based time control, generate the On Login script
        if (profile.useSchedulerTime && profile.schedulerInterval) {
            const onLoginScript = this.generateSchedulerScript(profile.schedulerInterval);
            params.push(`=on-login=${onLoginScript}`);
            // Don't set session-timeout when using scheduler
        } else if (profile.limitUptime) {
            // Real-time expiry: use the dynamic scheduler on-login script
            // so time counts down even when users are disconnected.
            // The duration is read from each user's comment field on login.
            const onLoginScript = this.generateDynamicSchedulerScript();
            params.push(`=on-login=${onLoginScript}`);
        } else {
            // Legacy session-timeout support (per-session, resets on reconnect)
            if (profile.sessionTimeout) {
                params.push(`=session-timeout=${profile.sessionTimeout}`);
            }
        }

        // Custom on-login script (if provided directly, overrides auto-generated ones)
        if (profile.onLoginScript && !profile.useSchedulerTime && !profile.limitUptime) {
            params.push(`=on-login=${profile.onLoginScript}`);
        }

        if (profile.sharedUsers) {
            params.push(`=shared-users=${profile.sharedUsers}`);
        }
        if (profile.idleTimeout) {
            params.push(`=idle-timeout=${profile.idleTimeout}`);
        }
        if (profile.keepaliveTimeout) {
            params.push(`=keepalive-timeout=${profile.keepaliveTimeout}`);
        }

        const result = await this.executeCommand(
            connection,
            '/ip/hotspot/user/profile/add',
            params
        );

        if (!result.success) {
            this.logger.error(`Failed to create hotspot profile: ${result.error}`);
            return { success: false, error: result.error };
        }

        return { success: true };
    }

    /**
     * Generate MikroTik On Login script for scheduler-based time control
     * Creates a scheduler that removes the user after the interval expires
     * Compatible with both RouterOS v6 and v7 (uses space syntax)
     */
    private generateSchedulerScript(interval: string): string {
        // MikroTik script that creates a scheduler on user login
        // The scheduler auto-removes the user when time expires
        // Uses RouterOS v6 compatible syntax (spaces) which also works on v7
        return `{
:local voucher \\$user;
:if ([/system scheduler find name=\\$voucher]="") do={
/system scheduler add comment=\\$voucher name=\\$voucher interval=${interval} on-event="/ip hotspot active remove [find user=\\$voucher]\\r\\n/ip hotspot user remove [find name=\\$voucher]\\r\\n/system scheduler remove [find name=\\$voucher]"
}
}`;
    }

    /**
     * Generate a dynamic On Login script that reads the duration from
     * each user's comment field. This allows per-user durations while
     * sharing a single profile. A scheduler is created on first login
     * that counts down in REAL TIME and removes the user when it expires.
     * Compatible with both RouterOS v6 and v7 (uses space syntax).
     */
    private generateDynamicSchedulerScript(): string {
        return `{
:local voucher \\$user;
:local duration [/ip hotspot user get [find name=\\$voucher] comment];
:if (\\$duration != "") do={
:if ([/system scheduler find name=\\$voucher] = "") do={
/system scheduler add name=\\$voucher interval=\\$duration on-event="/ip hotspot active remove [find user=\\$voucher]\\r\\n/ip hotspot user remove [find name=\\$voucher]\\r\\n/system scheduler remove [find name=\\$voucher]"
}
}
}`;
    }

    /**
     * Ensure a hotspot user profile has the dynamic on-login scheduler script.
     * This sets the profile's on-login script so that when any user of this
     * profile logs in, a real-time scheduler is created based on the user's
     * comment field (which stores the duration).
     */
    async ensureProfileOnLoginScript(
        connection: MikroTikConnection,
        profileName: string,
    ): Promise<void> {
        const script = this.generateDynamicSchedulerScript();
        const result = await this.executeCommand(connection, '/ip/hotspot/user/profile/set', [
            `=numbers=${profileName}`,
            `=on-login=${script}`,
        ]);

        if (!result.success) {
            this.logger.warn(`Failed to set on-login script for profile ${profileName}: ${result.error}`);
        } else {
            this.logger.debug(`Set dynamic scheduler on-login script on profile: ${profileName}`);
        }
    }

    /**
     * Get all hotspot users
     */
    async getHotspotUsers(connection: MikroTikConnection): Promise<any[]> {
        const result = await this.executeCommand(connection, '/ip/hotspot/user/print');

        if (!result.success) {
            this.logger.warn(`Failed to get hotspot users: ${result.error}`);
            return [];
        }

        this.logger.log(`Found ${(result.data || []).length} hotspot users`);
        return result.data || [];
    }

    /**
     * Get router interfaces
     */
    async getInterfaces(connection: MikroTikConnection): Promise<any[]> {
        const result = await this.executeCommand(connection, '/interface/print');

        if (!result.success) {
            this.logger.warn(`Failed to get interfaces: ${result.error}`);
            return [];
        }

        return result.data || [];
    }

    /**
     * Get interface traffic stats
     */
    async getInterfaceTraffic(connection: MikroTikConnection): Promise<any[]> {
        const result = await this.executeCommand(connection, '/interface/print', ['=stats']);

        if (!result.success) {
            return [];
        }

        return result.data || [];
    }

    /**
     * Reboot router
     */
    async rebootRouter(connection: MikroTikConnection): Promise<MikroTikCommandResult> {
        return this.executeCommand(connection, '/system/reboot');
    }

    /**
     * Get system logs
     */
    async getSystemLogs(connection: MikroTikConnection, limit: number = 50): Promise<any[]> {
        // Use a longer timeout for logs as they can be large
        const api = new RouterOSAPI({
            host: connection.host,
            user: connection.username,
            password: connection.password,
            port: connection.port,
            timeout: 30, // Extended timeout for logs
        });

        try {
            await api.connect();

            // Get only the last N logs to avoid timeout
            const response = await api.write('/log/print', [
                `=.proplist=.id,time,topics,message`,
            ]);

            await api.close();

            // Return last N logs, most recent first
            const logs = response || [];
            return logs.slice(-limit).reverse();
        } catch (error) {
            this.logger.warn(`Failed to get system logs: ${error.message}`);
            try {
                await api.close();
            } catch (e) {
                // Ignore close errors
            }
            return [];
        }
    }

    /**
     * Add a RADIUS server to MikroTik router
     * Configures the router to forward hotspot auth to FreeRADIUS
     */
    async addRadiusServer(
        connection: MikroTikConnection,
        radiusServerIp: string,
        secret: string,
        authPort: number = 1812,
        acctPort: number = 1813,
    ): Promise<MikroTikCommandResult> {
        this.logger.log(`Adding RADIUS server ${radiusServerIp} to ${connection.host}`);

        // First check if a RADIUS entry for this server already exists
        const existing = await this.executeCommand(connection, '/radius/print', [
            `?address=${radiusServerIp}`,
        ]);

        if (existing.success && existing.data && existing.data.length > 0) {
            // Update existing entry
            const id = existing.data[0]['.id'];
            this.logger.log(`Updating existing RADIUS entry ${id} on ${connection.host}`);
            return this.executeCommand(connection, '/radius/set', [
                `=.id=${id}`,
                `=service=hotspot`,
                `=address=${radiusServerIp}`,
                `=secret=${secret}`,
                `=authentication-port=${authPort}`,
                `=accounting-port=${acctPort}`,
                `=timeout=3000ms`,
            ]);
        }

        // Create new RADIUS server entry
        this.logger.log(`Creating RADIUS entry: address=${radiusServerIp}, service=hotspot, authPort=${authPort}, acctPort=${acctPort}`);
        const result = await this.executeCommand(connection, '/radius/add', [
            `=service=hotspot`,
            `=address=${radiusServerIp}`,
            `=secret=${secret}`,
            `=authentication-port=${authPort}`,
            `=accounting-port=${acctPort}`,
            `=timeout=3000ms`,
        ]);
        if (!result.success) {
            this.logger.error(`Failed to create RADIUS entry: ${result.error}`);
        } else {
            this.logger.log(`RADIUS entry created successfully on ${connection.host}`);
        }
        return result;
    }

    /**
     * Enable RADIUS authentication on the hotspot server profile
     * Sets use-radius=yes so MikroTik forwards auth requests to RADIUS
     */
    async enableHotspotRadius(connection: MikroTikConnection): Promise<MikroTikCommandResult> {
        this.logger.log(`Enabling RADIUS on hotspot for ${connection.host}`);

        // Get the hotspot server profile(s)
        const profiles = await this.executeCommand(connection, '/ip/hotspot/profile/print');

        if (!profiles.success || !profiles.data || profiles.data.length === 0) {
            this.logger.warn(`No hotspot server profiles found on ${connection.host}`);
            return { success: false, error: 'No hotspot server profiles found' };
        }

        // Enable RADIUS on all hotspot server profiles
        let lastResult: MikroTikCommandResult = { success: true };
        for (const profile of profiles.data) {
            const id = profile['.id'];
            lastResult = await this.executeCommand(connection, '/ip/hotspot/profile/set', [
                `=.id=${id}`,
                `=use-radius=yes`,
                `=radius-interim-update=00:05:00`,
            ]);

            if (!lastResult.success) {
                this.logger.error(`Failed to enable RADIUS on profile ${profile.name}: ${lastResult.error}`);
            }
        }

        return lastResult;
    }

    /**
     * Remove RADIUS server entry from MikroTik router
     * Used when a router is being removed from the system
     */
    async removeRadiusServer(
        connection: MikroTikConnection,
        radiusServerIp: string,
    ): Promise<MikroTikCommandResult> {
        this.logger.log(`Removing RADIUS server ${radiusServerIp} from ${connection.host}`);

        // Find the RADIUS entry for this server
        const existing = await this.executeCommand(connection, '/radius/print', [
            `?address=${radiusServerIp}`,
        ]);

        if (!existing.success || !existing.data || existing.data.length === 0) {
            this.logger.debug(`No RADIUS entry found for ${radiusServerIp} on ${connection.host}`);
            return { success: true }; // Nothing to remove
        }

        // Remove each matching entry
        for (const entry of existing.data) {
            const id = entry['.id'];
            await this.executeCommand(connection, '/radius/remove', [`=.id=${id}`]);
        }

        return { success: true };
    }
}
