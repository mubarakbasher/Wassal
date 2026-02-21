-- CreateEnum
CREATE TYPE "CountType" AS ENUM ('WALL_CLOCK', 'ONLINE_ONLY');

-- AlterTable
ALTER TABLE "radacct" ALTER COLUMN "acctsessionid" DROP NOT NULL,
ALTER COLUMN "acctuniqueid" DROP NOT NULL,
ALTER COLUMN "username" DROP NOT NULL,
ALTER COLUMN "realm" DROP NOT NULL,
ALTER COLUMN "realm" DROP DEFAULT,
ALTER COLUMN "nasipaddress" DROP NOT NULL,
ALTER COLUMN "calledstationid" DROP NOT NULL,
ALTER COLUMN "callingstationid" DROP NOT NULL,
ALTER COLUMN "acctterminatecause" DROP NOT NULL,
ALTER COLUMN "acctterminatecause" DROP DEFAULT,
ALTER COLUMN "framedipaddress" DROP NOT NULL,
ALTER COLUMN "framedipaddress" DROP DEFAULT,
ALTER COLUMN "framedipv6address" DROP NOT NULL,
ALTER COLUMN "framedipv6address" DROP DEFAULT,
ALTER COLUMN "framedipv6prefix" DROP NOT NULL,
ALTER COLUMN "framedipv6prefix" DROP DEFAULT,
ALTER COLUMN "framedinterfaceid" DROP NOT NULL,
ALTER COLUMN "framedinterfaceid" DROP DEFAULT,
ALTER COLUMN "delegatedipv6prefix" DROP NOT NULL,
ALTER COLUMN "delegatedipv6prefix" DROP DEFAULT;

-- AlterTable
ALTER TABLE "vouchers" ADD COLUMN     "countType" "CountType" NOT NULL DEFAULT 'WALL_CLOCK';
