import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateContactMessageDto } from './dto/create-message.dto';

@Injectable()
export class ContactMessagesService {
    constructor(private prisma: PrismaService) {}

    async create(userId: string, dto: CreateContactMessageDto) {
        return this.prisma.contactMessage.create({
            data: {
                subject: dto.subject,
                message: dto.message,
                userId,
            },
        });
    }

    async findByUser(userId: string) {
        return this.prisma.contactMessage.findMany({
            where: { userId },
            orderBy: { createdAt: 'desc' },
        });
    }
}
