import { PrismaClient } from '@prisma/client';
const RouterOSAPI = require('node-routeros').RouterOSAPI;

const prisma = new PrismaClient();

async function checkMikroTikConfig() {
    const routers = await prisma.router.findMany();

    for (const router of routers) {
        if (router.ipAddress === '192.168.1.67') {
            console.log(`Checking MikroTik: ${router.ipAddress}`);

            const api = new RouterOSAPI({
                host: router.ipAddress,
                user: router.username,
                password: router.password,
                port: router.apiPort,
                timeout: 10
            });

            try {
                await api.connect();

                console.log('\n--- RADIUS Servers on MikroTik ---');
                const radiusConfig = await api.write('/radius/print');
                console.log(radiusConfig);

                console.log('\n--- Hotspot Server Profiles ---');
                const hotspotProfiles = await api.write('/ip/hotspot/profile/print');
                console.log(hotspotProfiles.map(p => ({
                    name: p.name,
                    'use-radius': p['use-radius'],
                    'login-by': p['login-by']
                })));

                await api.close();
            } catch (e) {
                console.error(`Failed to connect to ${router.ipAddress}: ${e.message}`);
            }
        }
    }
}

checkMikroTikConfig()
    .catch(console.error)
    .finally(() => prisma.$disconnect());
