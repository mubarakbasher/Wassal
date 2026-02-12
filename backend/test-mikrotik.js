// Quick test script for MikroTik API connection
const RouterOSAPI = require('node-routeros').RouterOSAPI;

async function testMikrotikConnection() {
    console.log('Testing MikroTik connection to 192.168.1.68:8728...');

    const api = new RouterOSAPI({
        host: '192.168.1.68',
        user: 'wassal_auto',
        password: 'Wassal@123',
        port: 8728,
        timeout: 10,
    });

    try {
        console.log('Connecting...');
        const startTime = Date.now();
        await api.connect();
        console.log(`Connected in ${Date.now() - startTime}ms`);

        console.log('Getting identity...');
        const identity = await api.write('/system/identity/print');
        console.log('Identity:', identity);

        console.log('Getting uptime...');
        const resource = await api.write('/system/resource/print');
        console.log('Uptime:', resource[0]?.uptime);

        console.log('Getting active sessions...');
        const sessions = await api.write('/ip/hotspot/active/print');
        console.log('Active sessions:', sessions.length);

        await api.close();
        console.log('Test completed successfully!');
    } catch (error) {
        console.error('Error:', error.message);
        try { await api.close(); } catch (e) { }
    }
}

testMikrotikConnection();
