/*
  Warnings:

  - You are about to drop the column `headers` on the `webhook_logs` table. All the data in the column will be lost.

*/
-- CreateEnum
CREATE TYPE "whatsapp"."WhatsappMessageType" AS ENUM ('TEXT', 'IMAGE', 'VIDEO', 'AUDIO', 'DOCUMENT', 'STICKER', 'VIDEO_NOTE', 'LOCATION', 'LIVE_LOCATION', 'CONTACT', 'CONTACTS_ARRAY', 'REACTION');

-- AlterTable
ALTER TABLE "whatsapp"."webhook_logs" DROP COLUMN "headers";

-- CreateTable
CREATE TABLE "whatsapp"."whatsapp_messages" (
    "id" TEXT NOT NULL,
    "webhook_log_id" TEXT NOT NULL,
    "chat_id" VARCHAR(50) NOT NULL,
    "chat_lid" VARCHAR(60),
    "from" VARCHAR(50) NOT NULL,
    "from_lid" VARCHAR(60),
    "from_name" VARCHAR(100),
    "is_from_me" BOOLEAN NOT NULL DEFAULT false,
    "wa_timestamp" TIMESTAMP(3) NOT NULL,
    "message_type" "whatsapp"."WhatsappMessageType" NOT NULL,
    "body" TEXT,
    "replied_to_id" VARCHAR(100),
    "quoted_body" TEXT,
    "is_forwarded" BOOLEAN NOT NULL DEFAULT false,
    "media_path" VARCHAR(500),
    "media_caption" TEXT,
    "latitude" DOUBLE PRECISION,
    "longitude" DOUBLE PRECISION,
    "location_thumbnail" TEXT,
    "location_sequence" BIGINT,
    "contact_name" VARCHAR(100),
    "contact_vcard" TEXT,
    "contacts" JSONB,
    "reaction" VARCHAR(10),
    "reacted_message_id" VARCHAR(100),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "whatsapp_messages_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "whatsapp_messages_webhook_log_id_idx" ON "whatsapp"."whatsapp_messages"("webhook_log_id");

-- CreateIndex
CREATE INDEX "whatsapp_messages_chat_id_idx" ON "whatsapp"."whatsapp_messages"("chat_id");

-- CreateIndex
CREATE INDEX "whatsapp_messages_from_idx" ON "whatsapp"."whatsapp_messages"("from");

-- CreateIndex
CREATE INDEX "whatsapp_messages_wa_timestamp_idx" ON "whatsapp"."whatsapp_messages"("wa_timestamp");

-- CreateIndex
CREATE INDEX "whatsapp_messages_message_type_idx" ON "whatsapp"."whatsapp_messages"("message_type");

-- AddForeignKey
ALTER TABLE "whatsapp"."whatsapp_messages" ADD CONSTRAINT "whatsapp_messages_webhook_log_id_fkey" FOREIGN KEY ("webhook_log_id") REFERENCES "whatsapp"."webhook_logs"("id") ON DELETE CASCADE ON UPDATE CASCADE;
