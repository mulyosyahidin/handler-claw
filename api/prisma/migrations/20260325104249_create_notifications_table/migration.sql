-- CreateEnum
CREATE TYPE "NotificationStatus" AS ENUM ('PENDING', 'SENT', 'FAILED');

-- CreateTable
CREATE TABLE "notifications" (
    "id" TEXT NOT NULL,
    "reminder_hook_id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "user_device_id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "body" TEXT NOT NULL,
    "data" JSONB,
    "triggered_at" TIMESTAMP(3),
    "status" "NotificationStatus" NOT NULL DEFAULT 'PENDING',
    "fcm_message_id" TEXT,
    "sent_at" TIMESTAMP(3),
    "failed_at" TIMESTAMP(3),
    "retryCount" INTEGER NOT NULL DEFAULT 0,
    "error_message" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "notifications_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "notifications_status_idx" ON "notifications"("status");

-- CreateIndex
CREATE INDEX "notifications_user_id_idx" ON "notifications"("user_id");

-- CreateIndex
CREATE INDEX "notifications_user_device_id_idx" ON "notifications"("user_device_id");

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_reminder_hook_id_fkey" FOREIGN KEY ("reminder_hook_id") REFERENCES "reminder_hooks"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_user_device_id_fkey" FOREIGN KEY ("user_device_id") REFERENCES "user_devices"("id") ON DELETE CASCADE ON UPDATE CASCADE;
