/*
  Warnings:

  - Added the required column `updated_at` to the `balance_snapshots` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "finance"."account_types" ADD COLUMN     "deleted_at" TIMESTAMP(3);

-- AlterTable
ALTER TABLE "finance"."accounts" ADD COLUMN     "deleted_at" TIMESTAMP(3);

-- AlterTable
ALTER TABLE "finance"."balance_snapshots" ADD COLUMN     "deleted_at" TIMESTAMP(3),
ADD COLUMN     "updated_at" TIMESTAMP(3) NOT NULL;
