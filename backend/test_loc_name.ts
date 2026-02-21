import { PrismaClient } from '@prisma/client';
const RouterOSAPI = require('node-routeros').RouterOSAPI;
import * as crypto from 'crypto';

const prisma = new PrismaClient();

function decryptPassword(encryptedPassword) {
    const algorithm = 'aes-256-cbc';
    const key = crypto.scryptSync('your-super-secret-jwt-key-change-this-in-production', 'salt', 32);

    const parts = encryptedPassword.split(':');
    const iv = Buffer.from(parts[0], 'hex');
    const encrypted = parts[1];

    const decipher = crypto.createDecipheriv(algorithm, key, iv);
    let decrypted = decipher.update(encrypted, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    return decrypted;
}

async function testLocName() {
    const router = await prisma.router.findFirst({ where: { ipAddress: '192.168.1.128' } });
    if (!router) return;
    const pw = decryptPassword(router.password);

    const api = new RouterOSAPI({ host: router.ipAddress, user: router.username, password: pw, port: router.apiPort });
    await api.connect();
    const res = await api.write('/ip/hotspot/profile/print');
    console.log(res.map(p => ({
        name: p.name,
        location: p['radius-location-name'],
    })));
    await api.close();
}

testLocName().finally(() => prisma.$disconnect());
