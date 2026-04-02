-- CreateTable
CREATE TABLE "whatsapp_logs" (
    "id" TEXT NOT NULL,
    "received_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "device" VARCHAR(30) NOT NULL,
    "mode" VARCHAR(10) NOT NULL,
    "sender" VARCHAR(50) NOT NULL,
    "sender_lid" VARCHAR(60),
    "sender_name" VARCHAR(100),
    "is_group" BOOLEAN NOT NULL DEFAULT false,
    "group_id" VARCHAR(60),
    "member_phone" VARCHAR(30),
    "member_lid" VARCHAR(60),
    "message_text" TEXT,
    "message_type" VARCHAR(20) NOT NULL,
    "is_forwarded" BOOLEAN NOT NULL DEFAULT false,
    "is_quick" BOOLEAN NOT NULL DEFAULT false,
    "inbox_id" INTEGER NOT NULL DEFAULT 0,
    "extension" VARCHAR(20),
    "filename" VARCHAR(255),
    "url" VARCHAR(500),
    "location" VARCHAR(255),
    "poll_name" VARCHAR(255),
    "poll_choices" JSONB,
    "wa_timestamp" BIGINT NOT NULL,

    CONSTRAINT "whatsapp_logs_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "whatsapp_logs_sender_idx" ON "whatsapp_logs"("sender");

-- CreateIndex
CREATE INDEX "whatsapp_logs_device_idx" ON "whatsapp_logs"("device");

-- CreateIndex
CREATE INDEX "whatsapp_logs_received_at_idx" ON "whatsapp_logs"("received_at");

-- CreateIndex
CREATE INDEX "whatsapp_logs_is_group_idx" ON "whatsapp_logs"("is_group");
