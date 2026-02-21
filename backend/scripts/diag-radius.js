// Minimal diagnostic with logging to file
const fs = require('fs');
const { RouterOSAPI } = require('node-routeros');
const { PrismaClient } = require('@prisma/client');
const crypto = require('crypto');
require('dotenv').config();

const logFile = 'scripts/diag-output.txt';
const log = (msg) => {
    const line = typeof msg === 'string' ? msg : JSON.stringify(msg, null, 2);
    fs.appendFileSync(logFile, line + '\n');
    console.log(line);
};

// Clear previous log
fs.writeFileSync(logFile, '');

process.on('uncaughtException', (err) => {
    log('UNCAUGHT: errno=' + err.errno + ' msg=' + err.message);
});

const prisma = new PrismaClient();

function decrypt(enc) {
    const key = crypto.scryptSync(process.env.JWT_SECRET || 'secret', 'salt', 32);
    const parts = enc.split(':');
    const iv = Buffer.from(parts[0], 'hex');
    const decipher = crypto.createDecipheriv('aes-256-cbc', key, iv);
    return decipher.update(parts[1], 'hex', 'utf8') + decipher.final('utf8');
}

async function main() {
    const router = await prisma.router.findFirst({ where: { ipAddress: '192.168.1.67' } });
    if (!router) { log('NO ROUTER FOUND'); process.exit(1); }

    const pw = decrypt(router.password);
    log('Router: ' + router.name + ' | IP: ' + router.ipAddress + ':' + router.apiPort);
    log('Username: ' + router.username);
    log('Password: ' + pw);
    log('RADIUS_SERVER_IP: ' + (process.env.RADIUS_SERVER_IP || 'NOT SET'));
    log('radiusSecret: ' + (router.radiusSecret || 'NONE'));
    log('');

    const api = new RouterOSAPI({
        host: router.ipAddress,
        port: router.apiPort,
        user: router.username,
        password: pw,
        timeout: 30,
    });

    log('1. Connecting...');
    try {
        await api.connect();
        log('   CONNECTED OK');
    } catch (e) {
        log('   CONNECT FAILED: ' + e.errno + ' ' + e.message);
        process.exit(1);
    }

    log('2. /system/identity/print');
    try {
        const r = await api.write('/system/identity/print');
        log('   Result: ' + JSON.stringify(r));
    } catch (e) {
        log('   ERROR: ' + e.errno + ' ' + e.message);
    }

    // Wait a bit between commands
    await new Promise(r => setTimeout(r, 500));

    log('3. /radius/print');
    try {
        const r = await api.write('/radius/print');
        log('   Result: ' + JSON.stringify(r));
    } catch (e) {
        log('   ERROR: ' + e.errno + ' ' + e.message);
        if (e.errno === 'UNKNOWNREPLY') {
            log('   (UNKNOWNREPLY - this means no RADIUS entries exist, which is expected)');
        }
    }

    await new Promise(r => setTimeout(r, 500));

    log('4. /radius/add');
    const radiusIp = process.env.RADIUS_SERVER_IP || '192.168.1.227';
    const secret = router.radiusSecret || 'test-secret';
    try {
        const r = await api.write('/radius/add', [
            '=service=hotspot',
            '=address=' + radiusIp,
            '=secret=' + secret,
            '=authentication-port=1812',
            '=accounting-port=1813',
            '=timeout=3000ms',
        ]);
        log('   Result: ' + JSON.stringify(r));
    } catch (e) {
        log('   ERROR: ' + e.errno + ' ' + e.message);
    }

    await new Promise(r => setTimeout(r, 500));

    log('5. /radius/print (verify)');
    try {
        const r = await api.write('/radius/print');
        log('   Result: ' + JSON.stringify(r));
    } catch (e) {
        log('   ERROR: ' + e.errno + ' ' + e.message);
    }

    await new Promise(r => setTimeout(r, 500));

    log('6. /ip/hotspot/profile/print');
    try {
        const r = await api.write('/ip/hotspot/profile/print');
        log('   Result: ' + JSON.stringify(r));
    } catch (e) {
        log('   ERROR: ' + e.errno + ' ' + e.message);
    }

    try { await api.close(); } catch (_) { }
    log('\nDONE - check scripts/diag-output.txt for full log');
    setTimeout(() => process.exit(0), 2000);
}

main().catch(e => { log('FATAL: ' + e.message); setTimeout(() => process.exit(1), 1000); });
