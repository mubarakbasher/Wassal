import { PrismaClient } from '@prisma/client';
import * as fs from 'fs';

const prisma = new PrismaClient();

async function checkVoucher() {
    const username = '13105145';

    const radCheck = await prisma.radCheck.findMany({
        where: { username }
    });

    const voucher = await prisma.voucher.findFirst({
        where: { username }
    });

    const router = await prisma.router.findMany();

    const nas = await prisma.nas.findMany();

    const output = {
        radCheck,
        voucher,
        router: router.map(r => ({ id: r.id, ip: r.ipAddress, nasname: r.ipAddress })),
        nas
    };

    fs.writeFileSync('voucher_debug.json', JSON.stringify(output, null, 2));
}

checkVoucher()
    .catch(console.error)
    .finally(() => prisma.$disconnect());
