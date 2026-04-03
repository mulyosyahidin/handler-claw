-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "whatsapp";

-- CreateTable
CREATE TABLE "whatsapp"."webhook_logs" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "device_id" TEXT NOT NULL,
    "payload" JSONB NOT NULL,
    "headers" JSONB NOT NULL,

    CONSTRAINT "webhook_logs_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "webhook_logs_user_id_idx" ON "whatsapp"."webhook_logs"("user_id");

-- AddForeignKey
ALTER TABLE "whatsapp"."webhook_logs" ADD CONSTRAINT "webhook_logs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
