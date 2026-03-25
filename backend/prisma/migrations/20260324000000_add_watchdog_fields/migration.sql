-- AlterTable
ALTER TABLE "routers" ADD COLUMN "watchdogEnabled" BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE "routers" ADD COLUMN "watchdogTarget" TEXT;
