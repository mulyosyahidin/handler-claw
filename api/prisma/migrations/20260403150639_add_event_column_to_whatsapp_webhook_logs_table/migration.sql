/*
  Warnings:

  - Added the required column `event` to the `webhook_logs` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "whatsapp"."webhook_logs" ADD COLUMN     "event" VARCHAR(255) NOT NULL;
