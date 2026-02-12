import { Injectable, ConflictException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import * as bcrypt from 'bcrypt';
import { UserRole } from '@prisma/client';

@Injectable()
export class UsersService {
    constructor(private prisma: PrismaService) { }

    async create(createUserDto: CreateUserDto) {
        const { email, password, name, role } = createUserDto;

        const existingUser = await this.prisma.user.findUnique({
            where: { email },
        });

        if (existingUser) {
            throw new ConflictException('User with this email already exists');
        }

        const hashedPassword = await bcrypt.hash(password, 10);

        const user = await this.prisma.user.create({
            data: {
                email,
                password: hashedPassword,
                name,
                role: role || UserRole.OPERATOR,
            },
            select: {
                id: true,
                email: true,
                name: true,
                networkName: true,
                role: true,
                isActive: true,
                createdAt: true,
                updatedAt: true,
            },
        });

        return user;
    }

    async findAll() {
        return this.prisma.user.findMany({
            select: {
                id: true,
                email: true,
                name: true,
                networkName: true,
                role: true,
                isActive: true,
                createdAt: true,
                updatedAt: true,
            },
        });
    }

    async findOne(id: string) {
        const user = await this.prisma.user.findUnique({
            where: { id },
            select: {
                id: true,
                email: true,
                name: true,
                networkName: true,
                role: true,
                isActive: true,
                createdAt: true,
                updatedAt: true,
            },
        });

        if (!user) {
            throw new NotFoundException(`User with ID ${id} not found`);
        }

        return user;
    }

    async update(id: string, updateUserDto: UpdateUserDto) {
        const user = await this.prisma.user.findUnique({
            where: { id },
        });

        if (!user) {
            throw new NotFoundException(`User with ID ${id} not found`);
        }

        const { password, ...rest } = updateUserDto;
        const data: any = { ...rest };

        if (password) {
            data.password = await bcrypt.hash(password, 10);
        }

        const updatedUser = await this.prisma.user.update({
            where: { id },
            data,
            select: {
                id: true,
                email: true,
                name: true,
                networkName: true,
                role: true,
                isActive: true,
                createdAt: true,
                updatedAt: true,
            },
        });

        return updatedUser;
    }

    async remove(id: string) {
        const user = await this.prisma.user.findUnique({
            where: { id },
        });

        if (!user) {
            throw new NotFoundException(`User with ID ${id} not found`);
        }

        return this.prisma.user.delete({
            where: { id },
            select: {
                id: true,
                email: true,
                name: true,
            },
        });
    }
}
