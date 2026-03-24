-- CreateEnum
CREATE TYPE "ReminderHookStatus" AS ENUM ('RECEIVED', 'PROCESSING', 'PROCESSED', 'FAILED');

-- CreateTable
CREATE TABLE "reminder_hooks" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "event_id" TEXT NOT NULL,
    "status" "ReminderHookStatus" NOT NULL DEFAULT 'RECEIVED',
    "headers_json" JSONB NOT NULL,
    "payload_json" JSONB NOT NULL,
    "error_message" TEXT,
    "processed_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "reminder_hooks_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "reminder_hooks_user_id_idx" ON "reminder_hooks"("user_id");

-- CreateIndex
CREATE INDEX "reminder_hooks_created_at_idx" ON "reminder_hooks"("created_at");

-- CreateIndex
CREATE UNIQUE INDEX "reminder_hooks_user_id_event_id_key" ON "reminder_hooks"("user_id", "event_id");

-- AddForeignKey
ALTER TABLE "reminder_hooks" ADD CONSTRAINT "reminder_hooks_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
