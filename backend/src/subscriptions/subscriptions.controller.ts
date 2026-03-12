import {
    Controller,
    Get,
    Post,
    Param,
    Body,
    UseGuards,
    UseInterceptors,
    UploadedFile,
    BadRequestException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname, join } from 'path';
import { existsSync, mkdirSync } from 'fs';
import { randomUUID } from 'crypto';
import { SubscriptionsService } from './subscriptions.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

const UPLOADS_DIR = join(process.cwd(), 'uploads', 'proofs');
if (!existsSync(UPLOADS_DIR)) {
    mkdirSync(UPLOADS_DIR, { recursive: true });
}

@Controller('subscriptions')
export class SubscriptionsController {
    constructor(private readonly subscriptionsService: SubscriptionsService) { }

    @Get('plans')
    getPlans() {
        return this.subscriptionsService.getAvailablePlans();
    }

    @Get('my')
    @UseGuards(JwtAuthGuard)
    getMySubscription(@CurrentUser() user: any) {
        return this.subscriptionsService.getMySubscription(user.id);
    }

    @Get('payments')
    @UseGuards(JwtAuthGuard)
    getMyPayments(@CurrentUser() user: any) {
        return this.subscriptionsService.getMyPayments(user.id);
    }

    @Get('bank-info')
    @UseGuards(JwtAuthGuard)
    getBankInfo() {
        return this.subscriptionsService.getBankInfo();
    }

    @Post('request')
    @UseGuards(JwtAuthGuard)
    requestSubscription(
        @CurrentUser() user: any,
        @Body() body: { planId: string },
    ) {
        return this.subscriptionsService.requestSubscription(user.id, body.planId);
    }

    @Post('payments/:id/proof')
    @UseGuards(JwtAuthGuard)
    @UseInterceptors(
        FileInterceptor('proof', {
            storage: diskStorage({
                destination: (_req, _file, cb) => cb(null, UPLOADS_DIR),
                filename: (_req, file, cb) => {
                    const uniqueName = `${randomUUID()}${extname(file.originalname)}`;
                    cb(null, uniqueName);
                },
            }),
            limits: { fileSize: 5 * 1024 * 1024 },
            fileFilter: (_req, file, cb) => {
                if (!file.mimetype.match(/^image\//)) {
                    return cb(new Error('Only image files are allowed'), false);
                }
                cb(null, true);
            },
        }),
    )
    async uploadProof(
        @CurrentUser() user: any,
        @Param('id') paymentId: string,
        @UploadedFile() file: Express.Multer.File,
    ) {
        if (!file) {
            throw new BadRequestException('Proof file is required');
        }
        const proofUrl = `/uploads/proofs/${file.filename}`;
        return this.subscriptionsService.uploadProof(user.id, paymentId, proofUrl);
    }
}
