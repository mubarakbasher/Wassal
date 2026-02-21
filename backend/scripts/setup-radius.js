// Setup RADIUS on router - uses separate connections per command to avoid !empty crash
const fs = require('fs');
const { RouterOSAPI } = require('node-routeros');
const { PrismaClient } = require('@prisma/client');
const crypto = require('crypto');
require('dotenv').config();

const prisma = new PrismaClient();
const logFile = 'scripts/setup-output.txt';
fs.writeFileSync(logFile, '');
const log = (msg) => { fs.appendFileSync(logFile, msg + '\n'); console.log(msg); };

function decrypt(enc) {
    const key = crypto.scryptSync(process.env.JWT_SECRET || 'secret', 'salt', 32);
    const parts = enc.split(':');
    const iv = Buffer.from(parts[0], 'hex');
    const decipher = crypto.createDecipheriv('aes-256-cbc', key, iv);
    return decipher.update(parts[1], 'hex', 'utf8') + decipher.final('utf8');
}

// Each command uses its own fresh connection to avoid !empty reply corrupting the session
async function runCommand(conn, command, params) {
    const api = new RouterOSAPI({
        host: conn.host, port: conn.port,
        user: conn.username, password: conn.password,
        timeout: 20,
    });
    try {
        await api.connect();
        const result = params ? await api.write(command, params) : await api.write(command);
        try { await api.close(); } catch (_) { }
        return { ok: true, data: result || [] };
    } catch (e) {
        try { await api.close(); } catch (_) { }
        if (e.errno === 'UNKNOWNREPLY') {
            return { ok: true, data: [], note: 'empty reply' };
        }
        return { ok: false, error: e.message, errno: e.errno };
    }
}

async function main() {
    const router = await prisma.router.findFirst({ where: { ipAddress: '192.168.1.67' } });
    if (!router) { log('NO ROUTER FOUND'); process.exit(1); }

    const pw = decrypt(router.password);
    const radiusIp = process.env.RADIUS_SERVER_IP || '192.168.1.227';
    const secret = router.radiusSecret || crypto.randomBytes(16).toString('hex');
    const conn = { host: router.ipAddress, port: router.apiPort, username: router.username, password: pw };

    log('Router: ' + router.name + ' | ' + router.ipAddress + ':' + router.apiPort);
    log('Username: ' + router.username);
    log('RADIUS IP: ' + radiusIp);
    log('Secret: ' + secret.substring(0, 8) + '...');
    log('');

    // Step 1: Just add RADIUS entry directly (skip /radius/print since it crashes on empty)
    log('=== Step 1: Add RADIUS server entry ===');
    const addResult = await runCommand(conn, '/radius/add', [
        '=service=hotspot',
        '=address=' + radiusIp,
        '=secret=' + secret,
        '=authentication-port=1812',
        '=accounting-port=1813',
        '=timeout=3000ms',
    ]);
    if (addResult.ok) {
        log('SUCCESS: RADIUS entry added! Result: ' + JSON.stringify(addResult.data));
    } else {
        // If it already exists, that's fine
        if (addResult.error && addResult.error.includes('already')) {
            log('RADIUS entry already exists - OK');
        } else {
            log('FAILED to add RADIUS: ' + addResult.error);
        }
    }

    // Step 2: Get hotspot profiles
    log('');
    log('=== Step 2: Enable RADIUS on hotspot profiles ===');
    const profilesResult = await runCommand(conn, '/ip/hotspot/profile/print');
    log('Profiles result: ok=' + profilesResult.ok + ' count=' + (profilesResult.data ? profilesResult.data.length : 0));

    if (profilesResult.ok && profilesResult.data.length > 0) {
        for (const prof of profilesResult.data) {
            log('Setting use-radius=yes on profile: ' + (prof.name || prof['.id']));
            const setResult = await runCommand(conn, '/ip/hotspot/profile/set', [
                '=.id=' + prof['.id'],
                '=use-radius=yes',
                '=radius-accounting=yes',
                '=radius-interim-update=00:05:00',
            ]);
            log('  Result: ok=' + setResult.ok + (setResult.error ? ' error=' + setResult.error : ''));
        }
    } else {
        log('No profiles found, checking if empty reply...');
        if (profilesResult.note === 'empty reply') {
            log('Got empty reply - no hotspot profiles configured on this router');
        }
    }

    // Step 3: Verify RADIUS was added
    log('');
    log('=== Step 3: Verification ===');
    const verifyResult = await runCommand(conn, '/radius/print');
    if (verifyResult.ok && verifyResult.data.length > 0) {
        log('RADIUS entries after setup:');
        for (const entry of verifyResult.data) {
            log('  address=' + entry.address + ' service=' + entry.service + ' secret=' + (entry.secret ? '***' : 'none'));
        }
    } else {
        log('Verify result: ' + JSON.stringify(verifyResult));
    }

    // Step 4: Update DB
    if (!router.radiusSecret) {
        await prisma.router.update({ where: { id: router.id }, data: { radiusSecret: secret } });
        log('Updated radiusSecret in DB');
    }

    log('');
    log('COMPLETE! Check MikroTik Winbox RADIUS window.');
    setTimeout(() => process.exit(0), 1000);
}

main().catch(e => { log('FATAL: ' + e.message); setTimeout(() => process.exit(1), 1000); });
