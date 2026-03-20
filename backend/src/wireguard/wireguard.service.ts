import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { execSync } from 'child_process';
import * as fs from 'fs';
import * as path from 'path';
import * as crypto from 'crypto';

@Injectable()
export class WireGuardService {
    private readonly logger = new Logger(WireGuardService.name);
    private readonly peersDir: string;
    private readonly serverPublicKey: string;
    private readonly serverEndpoint: string;
    private readonly vpnSubnetBase = '10.10.10';

    constructor(private prisma: PrismaService) {
        this.peersDir = process.env.WG_PEERS_DIR || '/app/wireguard-peers';
        this.serverPublicKey = process.env.WG_SERVER_PUBLIC_KEY || '';
        this.serverEndpoint = process.env.WG_SERVER_ENDPOINT || '';

        if (!this.serverPublicKey) {
            this.logger.warn('WG_SERVER_PUBLIC_KEY not set — WireGuard setup will not work');
        }

        try {
            if (!fs.existsSync(this.peersDir)) {
                fs.mkdirSync(this.peersDir, { recursive: true });
            }
        } catch {
            this.logger.warn(`Could not create peers directory: ${this.peersDir}`);
        }
    }

    /**
     * Generate a WireGuard Curve25519 keypair using the native `wg` CLI tool.
     * This guarantees 100% compatibility with WireGuard's key format.
     */
    generateKeyPair(): { privateKey: string; publicKey: string } {
        const privateKey = execSync('wg genkey', { encoding: 'utf-8' }).trim();
        const publicKey = execSync(`echo "${privateKey}" | wg pubkey`, {
            encoding: 'utf-8',
            shell: '/bin/sh',
        }).trim();

        return { privateKey, publicKey };
    }

    /**
     * Allocate the next available VPN IP from the 10.10.10.0/16 pool.
     * .1 is reserved for the VPS server. Starts at .2.
     *
     * Uses raw SQL to bypass the soft-delete middleware so that IPs held
     * by soft-deleted records (which still enforce the unique constraint)
     * are not re-allocated.
     */
    async allocateVpnIp(): Promise<string> {
        const usedIps = await this.prisma.$queryRaw<{ vpnIp: string }[]>`
            SELECT "vpnIp" FROM "routers" WHERE "vpnIp" IS NOT NULL
        `;

        const usedSet = new Set(usedIps.map((r) => r.vpnIp));

        // Scan 10.10.10.2 through 10.10.255.254
        for (let third = 10; third <= 255; third++) {
            for (let fourth = 2; fourth <= 254; fourth++) {
                const candidate = `10.10.${third}.${fourth}`;
                if (!usedSet.has(candidate)) {
                    return candidate;
                }
            }
        }

        throw new Error('VPN IP pool exhausted');
    }

    /**
     * Write a peer config file so the host watcher can add it to WireGuard.
     */
    addPeer(publicKey: string, vpnIp: string): void {
        const safeName = vpnIp.replace(/\./g, '_');
        const peerFile = path.join(this.peersDir, `${safeName}.conf`);

        const content = [
            `[Peer]`,
            `PublicKey = ${publicKey}`,
            `AllowedIPs = ${vpnIp}/32`,
            '',
        ].join('\n');

        try {
            fs.writeFileSync(peerFile, content, 'utf-8');
            this.triggerSync();
            this.logger.log(`Added WireGuard peer: ${vpnIp}`);
        } catch (err) {
            this.logger.error(`Failed to write peer config for ${vpnIp}: ${err}`);
        }
    }

    /**
     * Remove a peer config file.
     */
    removePeer(vpnIp: string): void {
        const safeName = vpnIp.replace(/\./g, '_');
        const peerFile = path.join(this.peersDir, `${safeName}.conf`);

        try {
            if (fs.existsSync(peerFile)) {
                fs.unlinkSync(peerFile);
                this.triggerSync();
                this.logger.log(`Removed WireGuard peer: ${vpnIp}`);
            }
        } catch (err) {
            this.logger.error(`Failed to remove peer config for ${vpnIp}: ${err}`);
        }
    }

    /**
     * Write a trigger file to signal the host watcher to reload WireGuard config.
     */
    private triggerSync(): void {
        try {
            const triggerFile = path.join(this.peersDir, '.trigger');
            fs.writeFileSync(triggerFile, Date.now().toString(), 'utf-8');
        } catch {
            this.logger.warn('Could not write WireGuard sync trigger');
        }
    }

    /**
     * Build the MikroTik RouterOS v7 WireGuard setup script.
     */
    generateMikrotikScript(
        routerPrivateKey: string,
        vpnIp: string,
        userId: string,
        callbackBaseUrl: string,
    ): { steps: { title: string; command: string; description: string }[] } {
        const steps = [
            {
                title: 'Clean Previous Setup',
                description: 'Removes any existing Wassal WireGuard config for a clean start',
                command: `:do { /ip address remove [find interface=wg-wassal] } on-error={}; :do { /interface wireguard peers remove [find interface=wg-wassal] } on-error={}; :do { /interface wireguard remove wg-wassal } on-error={}`,
            },
            {
                title: 'Setup WireGuard VPN',
                description: 'Creates the WireGuard tunnel to Wassal cloud',
                command: [
                    '/interface wireguard add name=wg-wassal listen-port=13231 private-key="' + routerPrivateKey + '"',
                ].join(''),
            },
            {
                title: 'Connect to Wassal Server',
                description: 'Adds Wassal VPS as a WireGuard peer',
                command: [
                    '/interface wireguard peers add interface=wg-wassal',
                    ` public-key="${this.serverPublicKey}"`,
                    ` endpoint-address=${this.serverEndpoint.split(':')[0]}`,
                    ` endpoint-port=${this.serverEndpoint.split(':')[1] || '51820'}`,
                    ` allowed-address=10.10.0.0/16`,
                    ` persistent-keepalive=25`,
                ].join(''),
            },
            {
                title: 'Assign VPN Address',
                description: 'Sets the VPN IP on the WireGuard interface',
                command: `/ip address add address=${vpnIp}/16 interface=wg-wassal`,
            },
            {
                title: 'Allow API Access',
                description: 'Opens the MikroTik API port through the VPN',
                command: `/ip firewall filter add chain=input src-address=10.10.0.0/16 dst-port=8728 protocol=tcp action=accept comment="Wassal VPN API" place-before=0`,
            },
            {
                title: 'Create API User',
                description: 'Creates the management user for Wassal',
                command: `:do { /user remove wassal_auto } on-error={}; /user add name=wassal_auto group=full password=${process.env.MIKROTIK_AUTO_PASSWORD || 'WassalAuto2026'} comment="Wassal Auto-Connect"`,
            },
            {
                title: 'Enable API Service',
                description: 'Enables the RouterOS API service',
                command: '/ip service set api disabled=no',
            },
            {
                title: 'Register Router',
                description: 'Sends router info to Wassal for auto-discovery',
                command: (() => {
                    const secret = process.env.JWT_SECRET!;
                    const sig = crypto.createHmac('sha256', secret).update(userId).digest('hex').substring(0, 16);
                    return `/tool fetch url="${callbackBaseUrl}/public/routers/script-callback?vpnIp=${vpnIp}&userId=${userId}&sig=${sig}" mode=https check-certificate=no keep-result=no`;
                })(),
            },
        ];

        return { steps };
    }

    isConfigured(): boolean {
        return !!this.serverPublicKey && !!this.serverEndpoint;
    }
}
