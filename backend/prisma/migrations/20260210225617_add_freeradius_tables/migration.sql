-- AlterTable
ALTER TABLE "payments" ADD COLUMN     "planId" TEXT;

-- AlterTable
ALTER TABLE "routers" ADD COLUMN     "radiusSecret" TEXT;

-- AlterTable
ALTER TABLE "subscription_plans" ADD COLUMN     "description" TEXT;

-- CreateTable
CREATE TABLE "radcheck" (
    "id" SERIAL NOT NULL,
    "username" TEXT NOT NULL DEFAULT '',
    "attribute" TEXT NOT NULL DEFAULT '',
    "op" TEXT NOT NULL DEFAULT ':=',
    "value" TEXT NOT NULL DEFAULT '',

    CONSTRAINT "radcheck_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "radreply" (
    "id" SERIAL NOT NULL,
    "username" TEXT NOT NULL DEFAULT '',
    "attribute" TEXT NOT NULL DEFAULT '',
    "op" TEXT NOT NULL DEFAULT '=',
    "value" TEXT NOT NULL DEFAULT '',

    CONSTRAINT "radreply_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "radgroupcheck" (
    "id" SERIAL NOT NULL,
    "groupname" TEXT NOT NULL DEFAULT '',
    "attribute" TEXT NOT NULL DEFAULT '',
    "op" TEXT NOT NULL DEFAULT ':=',
    "value" TEXT NOT NULL DEFAULT '',

    CONSTRAINT "radgroupcheck_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "radgroupreply" (
    "id" SERIAL NOT NULL,
    "groupname" TEXT NOT NULL DEFAULT '',
    "attribute" TEXT NOT NULL DEFAULT '',
    "op" TEXT NOT NULL DEFAULT '=',
    "value" TEXT NOT NULL DEFAULT '',

    CONSTRAINT "radgroupreply_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "radusergroup" (
    "id" SERIAL NOT NULL,
    "username" TEXT NOT NULL DEFAULT '',
    "groupname" TEXT NOT NULL DEFAULT '',
    "priority" INTEGER NOT NULL DEFAULT 1,

    CONSTRAINT "radusergroup_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "radacct" (
    "radacctid" BIGSERIAL NOT NULL,
    "acctsessionid" VARCHAR(64) NOT NULL DEFAULT '',
    "acctuniqueid" VARCHAR(32) NOT NULL DEFAULT '',
    "username" VARCHAR(64) NOT NULL DEFAULT '',
    "realm" VARCHAR(64) NOT NULL DEFAULT '',
    "nasipaddress" VARCHAR(15) NOT NULL DEFAULT '',
    "nasportid" VARCHAR(32),
    "nasporttype" VARCHAR(32),
    "acctstarttime" TIMESTAMP(3),
    "acctupdatetime" TIMESTAMP(3),
    "acctstoptime" TIMESTAMP(3),
    "acctinterval" INTEGER,
    "acctsessiontime" INTEGER,
    "acctauthentic" VARCHAR(32),
    "connectinfo_start" VARCHAR(128),
    "connectinfo_stop" VARCHAR(128),
    "acctinputoctets" BIGINT,
    "acctoutputoctets" BIGINT,
    "calledstationid" VARCHAR(50) NOT NULL DEFAULT '',
    "callingstationid" VARCHAR(50) NOT NULL DEFAULT '',
    "acctterminatecause" VARCHAR(32) NOT NULL DEFAULT '',
    "servicetype" VARCHAR(32),
    "framedprotocol" VARCHAR(32),
    "framedipaddress" VARCHAR(15) NOT NULL DEFAULT '',
    "framedipv6address" VARCHAR(45) NOT NULL DEFAULT '',
    "framedipv6prefix" VARCHAR(45) NOT NULL DEFAULT '',
    "framedinterfaceid" VARCHAR(44) NOT NULL DEFAULT '',
    "delegatedipv6prefix" VARCHAR(45) NOT NULL DEFAULT '',
    "class" VARCHAR(64),

    CONSTRAINT "radacct_pkey" PRIMARY KEY ("radacctid")
);

-- CreateTable
CREATE TABLE "radpostauth" (
    "id" SERIAL NOT NULL,
    "username" TEXT NOT NULL DEFAULT '',
    "pass" TEXT NOT NULL DEFAULT '',
    "reply" TEXT NOT NULL DEFAULT '',
    "authdate" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "calledstationid" VARCHAR(50) NOT NULL DEFAULT '',
    "callingstationid" VARCHAR(50) NOT NULL DEFAULT '',

    CONSTRAINT "radpostauth_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "nas" (
    "id" SERIAL NOT NULL,
    "nasname" TEXT NOT NULL DEFAULT '',
    "shortname" TEXT,
    "type" VARCHAR(30) NOT NULL DEFAULT 'other',
    "ports" INTEGER,
    "secret" VARCHAR(60) NOT NULL DEFAULT 'secret',
    "server" VARCHAR(64),
    "community" VARCHAR(50),
    "description" VARCHAR(200),

    CONSTRAINT "nas_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "radcheck_username_idx" ON "radcheck"("username");

-- CreateIndex
CREATE INDEX "radreply_username_idx" ON "radreply"("username");

-- CreateIndex
CREATE INDEX "radgroupcheck_groupname_idx" ON "radgroupcheck"("groupname");

-- CreateIndex
CREATE INDEX "radgroupreply_groupname_idx" ON "radgroupreply"("groupname");

-- CreateIndex
CREATE INDEX "radusergroup_username_idx" ON "radusergroup"("username");

-- CreateIndex
CREATE UNIQUE INDEX "radacct_acctuniqueid_key" ON "radacct"("acctuniqueid");

-- CreateIndex
CREATE INDEX "radacct_username_idx" ON "radacct"("username");

-- CreateIndex
CREATE INDEX "radacct_acctsessionid_idx" ON "radacct"("acctsessionid");

-- CreateIndex
CREATE INDEX "radacct_nasipaddress_idx" ON "radacct"("nasipaddress");

-- CreateIndex
CREATE INDEX "radacct_acctstarttime_idx" ON "radacct"("acctstarttime");

-- CreateIndex
CREATE INDEX "radacct_acctstoptime_idx" ON "radacct"("acctstoptime");

-- CreateIndex
CREATE INDEX "radpostauth_username_idx" ON "radpostauth"("username");

-- CreateIndex
CREATE INDEX "nas_nasname_idx" ON "nas"("nasname");

-- AddForeignKey
ALTER TABLE "payments" ADD CONSTRAINT "payments_planId_fkey" FOREIGN KEY ("planId") REFERENCES "subscription_plans"("id") ON DELETE SET NULL ON UPDATE CASCADE;
