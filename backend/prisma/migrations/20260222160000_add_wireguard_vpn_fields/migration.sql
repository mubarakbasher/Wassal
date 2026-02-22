-- AlterTable
ALTER TABLE "routers" ADD COLUMN "vpnIp" TEXT;
ALTER TABLE "routers" ADD COLUMN "wgPublicKey" TEXT;
ALTER TABLE "routers" ADD COLUMN "wgPrivateKey" TEXT;

-- CreateIndex
CREATE UNIQUE INDEX "routers_vpnIp_key" ON "routers"("vpnIp");
