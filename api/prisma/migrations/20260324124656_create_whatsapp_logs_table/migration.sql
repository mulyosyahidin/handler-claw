-- CreateTable
CREATE TABLE "whatsapp_logs" (
    "id" SERIAL NOT NULL,
    "receivedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "device" VARCHAR(30) NOT NULL,
    "mode" VARCHAR(10) NOT NULL,
    "sender" VARCHAR(50) NOT NULL,
    "senderLid" VARCHAR(60),
    "senderName" VARCHAR(100),
    "isGroup" BOOLEAN NOT NULL DEFAULT false,
    "groupId" VARCHAR(60),
    "memberPhone" VARCHAR(30),
    "memberLid" VARCHAR(60),
    "messageText" TEXT,
    "messageType" VARCHAR(20) NOT NULL,
    "isForwarded" BOOLEAN NOT NULL DEFAULT false,
    "isQuick" BOOLEAN NOT NULL DEFAULT false,
    "inboxId" INTEGER NOT NULL DEFAULT 0,
    "extension" VARCHAR(20),
    "filename" VARCHAR(255),
    "url" VARCHAR(500),
    "location" VARCHAR(255),
    "pollName" VARCHAR(255),
    "pollChoices" JSONB,
    "waTimestamp" BIGINT NOT NULL,

    CONSTRAINT "whatsapp_logs_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "whatsapp_logs_sender_idx" ON "whatsapp_logs"("sender");

-- CreateIndex
CREATE INDEX "whatsapp_logs_device_idx" ON "whatsapp_logs"("device");

-- CreateIndex
CREATE INDEX "whatsapp_logs_receivedAt_idx" ON "whatsapp_logs"("receivedAt");

-- CreateIndex
CREATE INDEX "whatsapp_logs_isGroup_idx" ON "whatsapp_logs"("isGroup");
