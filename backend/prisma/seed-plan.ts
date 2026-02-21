import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
    const plan = await prisma.subscriptionPlan.upsert({
        where: { name: 'Pro' },
        update: {},
        create: {
            name: 'Pro',
            price: 0,
            durationDays: 365,
            description: 'Full access plan',
            maxRouters: 10,
            maxHotspotUsers: 0, // 0 = Unlimited
            allowReports: true,
            allowVouchers: true,
        },
    });
    console.log('Subscription plan created:', plan);
}

main()
    .catch((e) => {
        console.error(e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
