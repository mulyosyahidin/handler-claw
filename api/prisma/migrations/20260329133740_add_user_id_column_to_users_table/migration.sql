-- AlterTable
ALTER TABLE "whatsapp_logs" ADD COLUMN     "user_id" TEXT;

-- CreateIndex
CREATE INDEX "whatsapp_logs_user_id_idx" ON "whatsapp_logs"("user_id");

-- AddForeignKey
ALTER TABLE "whatsapp_logs" ADD CONSTRAINT "whatsapp_logs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
