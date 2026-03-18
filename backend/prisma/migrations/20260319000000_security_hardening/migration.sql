-- Security Hardening Migration
-- Adds: email verification, soft deletes, password reset codes, refresh tokens, email verification tokens

-- Add emailVerified and deletedAt to users
ALTER TABLE "users" ADD COLUMN "emailVerified" BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE "users" ADD COLUMN "deletedAt" TIMESTAMP(3);
CREATE INDEX "users_deletedAt_idx" ON "users"("deletedAt");

-- Add deletedAt to routers
ALTER TABLE "routers" ADD COLUMN "deletedAt" TIMESTAMP(3);
CREATE INDEX "routers_deletedAt_idx" ON "routers"("deletedAt");

-- Add deletedAt to vouchers
ALTER TABLE "vouchers" ADD COLUMN "deletedAt" TIMESTAMP(3);
CREATE INDEX "vouchers_deletedAt_idx" ON "vouchers"("deletedAt");

-- Add deletedAt to sales
ALTER TABLE "sales" ADD COLUMN "deletedAt" TIMESTAMP(3);
CREATE INDEX "sales_deletedAt_idx" ON "sales"("deletedAt");

-- Password Reset Codes (replaces in-memory Map)
CREATE TABLE "password_reset_codes" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "used" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "password_reset_codes_pkey" PRIMARY KEY ("id")
);
CREATE INDEX "password_reset_codes_email_idx" ON "password_reset_codes"("email");
CREATE INDEX "password_reset_codes_expiresAt_idx" ON "password_reset_codes"("expiresAt");

-- Refresh Tokens (supports revocation)
CREATE TABLE "refresh_tokens" (
    "id" TEXT NOT NULL,
    "token" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "revoked" BOOLEAN NOT NULL DEFAULT false,
    "revokedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "refresh_tokens_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "refresh_tokens_token_key" ON "refresh_tokens"("token");
CREATE INDEX "refresh_tokens_userId_idx" ON "refresh_tokens"("userId");
CREATE INDEX "refresh_tokens_token_idx" ON "refresh_tokens"("token");
CREATE INDEX "refresh_tokens_expiresAt_idx" ON "refresh_tokens"("expiresAt");
ALTER TABLE "refresh_tokens" ADD CONSTRAINT "refresh_tokens_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- Email Verification Tokens
CREATE TABLE "email_verification_tokens" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "token" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "used" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "email_verification_tokens_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "email_verification_tokens_token_key" ON "email_verification_tokens"("token");
CREATE INDEX "email_verification_tokens_email_idx" ON "email_verification_tokens"("email");
CREATE INDEX "email_verification_tokens_token_idx" ON "email_verification_tokens"("token");
