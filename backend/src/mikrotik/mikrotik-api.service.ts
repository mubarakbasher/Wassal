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
            timeout: 10,
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
            timeout: 10,
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
                data: response,
            };
        } catch (error) {
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
            throw new InternalServerErrorException('Failed to get system information');
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
            throw new InternalServerErrorException('Failed to get router uptime');
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
        limit?: string,
    ): Promise<MikroTikCommandResult> {
        const params = [
            `=name=${username}`,
            `=password=${password}`,
            `=profile=${profile}`,
        ];

        if (limit) {
            params.push(`=limit-uptime=${limit}`);
        }

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
            throw new InternalServerErrorException('Failed to get active sessions');
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
            throw new InternalServerErrorException('Failed to get hotspot profiles');
        }

        return result.data || [];
    }

    /**
     * Get all hotspot users
     */
    async getHotspotUsers(connection: MikroTikConnection): Promise<any[]> {
        const result = await this.executeCommand(connection, '/ip/hotspot/user/print');

        if (!result.success) {
            throw new InternalServerErrorException('Failed to get hotspot users');
        }

        return result.data || [];
    }
}
