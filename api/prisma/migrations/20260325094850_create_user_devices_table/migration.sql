-- CreateEnum
CREATE TYPE "UserDevicePlatform" AS ENUM ('ANDROID', 'IOS', 'WEB', 'WINDOWS');

-- CreateEnum
CREATE TYPE "UserDeviceStatus" AS ENUM ('ACTIVE', 'LOGGED_OUT', 'INVALID_TOKEN');

-- CreateTable
CREATE TABLE "user_devices" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "status" "UserDeviceStatus" NOT NULL DEFAULT 'ACTIVE',
    "device_id" TEXT NOT NULL,
    "device_brand" TEXT,
    "device_model" TEXT,
    "os_version" TEXT,
    "fcm_token" TEXT NOT NULL,
    "platform" "UserDevicePlatform" NOT NULL DEFAULT 'ANDROID',
    "last_seen_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "user_devices_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "user_devices_device_id_key" ON "user_devices"("device_id");

-- CreateIndex
CREATE INDEX "user_devices_user_id_idx" ON "user_devices"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_devices_user_id_device_id_key" ON "user_devices"("user_id", "device_id");

-- AddForeignKey
ALTER TABLE "user_devices" ADD CONSTRAINT "user_devices_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
