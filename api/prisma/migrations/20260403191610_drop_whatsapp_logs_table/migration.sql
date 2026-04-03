/*
  Warnings:

  - You are about to drop the `whatsapp_logs` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropForeignKey
ALTER TABLE "whatsapp_logs" DROP CONSTRAINT "whatsapp_logs_user_id_fkey";

-- DropTable
DROP TABLE "whatsapp_logs";
