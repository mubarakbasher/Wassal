import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function checkVoucher() {
    const username = '13105145';
    console.log(`Checking voucher for username: ${username}`);

    const radCheck = await prisma.radCheck.findMany({
        where: { username }
    });
    console.log('RadCheck:', radCheck);

    const voucher = await prisma.voucher.findFirst({
        where: { username }
    });
    console.log('Voucher in DB:', voucher);

    const router = await prisma.router.findMany();
    console.log('Routers:', router.map(r => ({ id: r.id, ip: r.ipAddress, nasname: r.ipAddress })));

    const nas = await prisma.nas.findMany();
    console.log('NAS configuration:', nas);
}

checkVoucher()
    .catch(console.error)
    .finally(() => prisma.$disconnect());
