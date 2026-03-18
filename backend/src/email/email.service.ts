import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Resend } from 'resend';

@Injectable()
export class EmailService {
    private readonly logger = new Logger(EmailService.name);
    private readonly resend: Resend;
    private readonly fromEmail: string;
    private readonly appDomain: string;

    constructor(private configService: ConfigService) {
        const apiKey = this.configService.get<string>('RESEND_API_KEY');
        this.fromEmail = this.configService.get<string>('RESEND_FROM_EMAIL') || 'noreply@example.com';
        this.resend = new Resend(apiKey);

        const domain = this.configService.get<string>('DOMAIN') || 'localhost';
        const port = this.configService.get<string>('PORT') || '3001';
        this.appDomain = this.configService.get<string>('NODE_ENV') === 'production'
            ? `https://api.${domain}`
            : `http://localhost:${port}`;
    }

    async sendResetCode(to: string, code: string): Promise<void> {
        try {
            const { data, error } = await this.resend.emails.send({
                from: this.fromEmail,
                to,
                subject: 'Password Reset Code - Wassal',
                html: `
                    <div style="font-family: Arial, sans-serif; max-width: 480px; margin: 0 auto; padding: 32px;">
                        <h2 style="color: #1a1a2e; margin-bottom: 16px;">Password Reset</h2>
                        <p style="color: #555; font-size: 15px; line-height: 1.6;">
                            You requested a password reset. Use the code below to reset your password.
                            This code expires in <strong>15 minutes</strong>.
                        </p>
                        <div style="background: #f4f4f8; border-radius: 12px; padding: 24px; text-align: center; margin: 24px 0;">
                            <span style="font-size: 36px; font-weight: bold; letter-spacing: 8px; color: #1a1a2e;">${code}</span>
                        </div>
                        <p style="color: #999; font-size: 13px;">
                            If you did not request this, you can safely ignore this email.
                        </p>
                    </div>
                `,
            });

            if (error) {
                throw new Error(`Resend error: ${error.message}`);
            }

            this.logger.log(`Reset code email sent to ${to}`);
        } catch (error) {
            this.logger.error(`Failed to send reset code email to ${to}`, error);
            throw error;
        }
    }

    async sendVerificationEmail(to: string, token: string): Promise<void> {
        const verifyUrl = `${this.appDomain}/auth/verify-email?token=${token}`;

        try {
            const { data, error } = await this.resend.emails.send({
                from: this.fromEmail,
                to,
                subject: 'Verify Your Email - Wassal',
                html: `
                    <div style="font-family: Arial, sans-serif; max-width: 480px; margin: 0 auto; padding: 32px;">
                        <h2 style="color: #1a1a2e; margin-bottom: 16px;">Verify Your Email</h2>
                        <p style="color: #555; font-size: 15px; line-height: 1.6;">
                            Welcome to Wassal! Please verify your email address by clicking the button below.
                            This link expires in <strong>24 hours</strong>.
                        </p>
                        <div style="text-align: center; margin: 24px 0;">
                            <a href="${verifyUrl}" style="background: #1a1a2e; color: white; padding: 14px 28px; border-radius: 8px; text-decoration: none; font-weight: bold; display: inline-block;">
                                Verify Email
                            </a>
                        </div>
                        <p style="color: #999; font-size: 13px;">
                            If the button doesn't work, copy and paste this link into your browser:<br/>
                            <a href="${verifyUrl}" style="color: #1a1a2e; word-break: break-all;">${verifyUrl}</a>
                        </p>
                        <p style="color: #999; font-size: 13px;">
                            If you did not create an account, you can safely ignore this email.
                        </p>
                    </div>
                `,
            });

            if (error) {
                throw new Error(`Resend error: ${error.message}`);
            }

            this.logger.log(`Verification email sent to ${to}`);
        } catch (error) {
            this.logger.error(`Failed to send verification email to ${to}`, error);
            throw error;
        }
    }
}
