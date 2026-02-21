import { PrismaClient } from '@prisma/client';
const RouterOSAPI = require('node-routeros').RouterOSAPI;
import * as crypto from 'crypto';
import * as dotenv from 'dotenv';
dotenv.config();

const prisma = new PrismaClient();

function decryptPassword(encryptedPassword: string): string {
    const algorithm = 'aes-256-cbc';
    const key = crypto.scryptSync(process.env.JWT_SECRET || 'secret', 'salt', 32);
    const parts = encryptedPassword.split(':');
    const iv = Buffer.from(parts[0], 'hex');
    const encrypted = parts[1];
    const decipher = crypto.createDecipheriv(algorithm, key, iv);
    let decrypted = decipher.update(encrypted, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    return decrypted;
}

async function run() {
    const router = await prisma.router.findFirst({ where: { ipAddress: '192.168.1.128' } });
    if (!router) return;
    const pwd = decryptPassword(router.password);

    const api = new RouterOSAPI({ host: router.ipAddress, user: router.username, password: pwd, port: router.apiPort });
    await api.connect();

    console.log("RADIUS configuration:", await api.write('/radius/print'));
    console.log("Hotspot Profile configuration:", await api.write('/ip/hotspot/profile/print'));

    await api.close();
}

run().finally(() => prisma.$disconnect());
