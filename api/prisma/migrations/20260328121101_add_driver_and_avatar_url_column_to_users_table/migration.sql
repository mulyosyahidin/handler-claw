-- CreateEnum
CREATE TYPE "UserDriver" AS ENUM ('EMAIL', 'GOOGLE');

-- AlterTable
ALTER TABLE "users" ADD COLUMN     "avatar_url" TEXT,
ADD COLUMN     "driver" "UserDriver" NOT NULL DEFAULT 'EMAIL',
ALTER COLUMN "password" DROP NOT NULL;
