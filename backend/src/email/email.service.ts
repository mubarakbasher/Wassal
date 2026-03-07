import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Resend } from 'resend';

@Injectable()
export class EmailService {
    private readonly logger = new Logger(EmailService.name);
    private readonly resend: Resend;
    private readonly fromEmail: string;

    constructor(private configService: ConfigService) {
        const apiKey = this.configService.get<string>('RESEND_API_KEY');
        this.fromEmail = this.configService.get<string>('RESEND_FROM_EMAIL') || 'noreply@example.com';
        // #region agent log
        this.logger.warn(`[DEBUG-e14aa1] H1/H3: EmailService init, apiKey=${apiKey ? 'SET(' + apiKey.substring(0, 6) + '...)' : 'MISSING'}, fromEmail=${this.fromEmail}`);
        // #endregion
        this.resend = new Resend(apiKey);
    }

    async sendResetCode(to: string, code: string): Promise<void> {
        // #region agent log
        this.logger.warn(`[DEBUG-e14aa1] H3: sendResetCode called, to=${to}, from=${this.fromEmail}`);
        // #endregion
        try {
            const { data, error } = await this.resend.emails.send({
                from: this.fromEmail,
                to,
                subject: 'Password Reset Code',
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
                // #region agent log
                this.logger.warn(`[DEBUG-e14aa1] H3: Resend API returned error=${JSON.stringify(error)}`);
                // #endregion
                throw new Error(`Resend error: ${error.message}`);
            }

            // #region agent log
            this.logger.warn(`[DEBUG-e14aa1] H3: Resend API success, emailId=${data?.id}`);
            // #endregion
            this.logger.log(`Reset code email sent to ${to}`);
        } catch (error) {
            // #region agent log
            this.logger.warn(`[DEBUG-e14aa1] H3: Resend send FAILED, error=${error?.message || error}`);
            // #endregion
            this.logger.error(`Failed to send reset code email to ${to}`, error);
            throw error;
        }
    }
}
