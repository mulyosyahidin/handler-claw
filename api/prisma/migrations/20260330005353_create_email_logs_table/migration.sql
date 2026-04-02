-- CreateEnum
CREATE TYPE "EmailLogStatus" AS ENUM ('SENT', 'FAILED');

-- CreateEnum
CREATE TYPE "EmailLogType" AS ENUM ('TEMPLATE', 'PLAIN');

-- CreateTable
CREATE TABLE "email_logs" (
    "id" TEXT NOT NULL,
    "from" TEXT NOT NULL,
    "to" TEXT NOT NULL,
    "subject" TEXT NOT NULL,
    "type" "EmailLogType" NOT NULL,
    "template_name" TEXT,
    "context" JSONB,
    "attachments" JSONB,
    "resend_id" TEXT,
    "status" "EmailLogStatus" NOT NULL,
    "error_message" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "email_logs_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "email_logs_status_idx" ON "email_logs"("status");

-- CreateIndex
CREATE INDEX "email_logs_created_at_idx" ON "email_logs"("created_at");
