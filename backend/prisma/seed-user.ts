import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
    // 1. Get the Pro plan (created by seed-plan.ts)
    let plan = await prisma.subscriptionPlan.findUnique({
        where: { name: 'Pro' },
    });

    if (!plan) {
        plan = await prisma.subscriptionPlan.create({
            data: {
                name: 'Pro',
                price: 0,
                durationDays: 365,
                description: 'Full access plan',
                maxRouters: 10,
                maxHotspotUsers: 0,
                allowReports: true,
                allowVouchers: true,
            },
        });
    }

    // 2. Create user
    const email = 'user@wassal.com';
    const password = 'password123';
    const hashedPassword = await bcrypt.hash(password, 10);

    const user = await prisma.user.upsert({
        where: { email },
        update: {},
        create: {
            email,
            name: 'Wassal User',
            password: hashedPassword,
            role: 'OPERATOR',
            isActive: true,
        },
    });

    // 3. Create subscription for user
    const expiresAt = new Date();
    expiresAt.setFullYear(expiresAt.getFullYear() + 1); // 1 year from now

    await prisma.userSubscription.upsert({
        where: { userId: user.id },
        update: {},
        create: {
            userId: user.id,
            planId: plan.id,
            status: 'ACTIVE',
            expiresAt,
        },
    });

    console.log('User created:', email);
    console.log('Password:', password);
    console.log('Subscription: Pro (1 year)');
}

main()
    .catch((e) => {
        console.error(e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
