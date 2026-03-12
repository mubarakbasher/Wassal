import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { NotificationsService } from '../../notifications/notifications.service';

@Injectable()
export class AdminMessagesService {
    constructor(
        private prisma: PrismaService,
        private notifications: NotificationsService,
    ) {}

    async findAll(page: number = 1, limit: number = 10, status?: string, search?: string) {
        const skip = (page - 1) * limit;
        const where: any = {};

        if (status && status !== 'ALL') {
            where.status = status;
        }

        if (search) {
            where.OR = [
                { subject: { contains: search, mode: 'insensitive' } },
                { message: { contains: search, mode: 'insensitive' } },
                { user: { name: { contains: search, mode: 'insensitive' } } },
                { user: { email: { contains: search, mode: 'insensitive' } } },
            ];
        }

        const [messages, total] = await Promise.all([
            this.prisma.contactMessage.findMany({
                where,
                skip,
                take: limit,
                include: {
                    user: { select: { id: true, email: true, name: true } },
                },
                orderBy: { createdAt: 'desc' },
            }),
            this.prisma.contactMessage.count({ where }),
        ]);

        return {
            data: messages,
            meta: { total, page, lastPage: Math.ceil(total / limit) },
        };
    }

    async getStats() {
        const [unread, total] = await Promise.all([
            this.prisma.contactMessage.count({ where: { status: 'UNREAD' } }),
            this.prisma.contactMessage.count(),
        ]);
        return { unread, total };
    }

    async findOne(id: string) {
        const message = await this.prisma.contactMessage.findUnique({
            where: { id },
            include: {
                user: { select: { id: true, email: true, name: true } },
            },
        });
        if (!message) throw new NotFoundException('Message not found');
        return message;
    }

    async markAsRead(id: string) {
        const message = await this.prisma.contactMessage.findUnique({ where: { id } });
        if (!message) throw new NotFoundException('Message not found');

        return this.prisma.contactMessage.update({
            where: { id },
            data: { status: 'READ' },
        });
    }

    async reply(id: string, replyText: string) {
        const message = await this.prisma.contactMessage.findUnique({ where: { id } });
        if (!message) throw new NotFoundException('Message not found');

        const updated = await this.prisma.contactMessage.update({
            where: { id },
            data: {
                reply: replyText,
                status: 'REPLIED',
                repliedAt: new Date(),
            },
        });

        await this.notifications.sendToUser(
            message.userId,
            'New Reply to Your Message',
            `Your message "${message.subject}" has received a reply.`,
            { type: 'contact_reply', messageId: id },
        );

        return updated;
    }
}
