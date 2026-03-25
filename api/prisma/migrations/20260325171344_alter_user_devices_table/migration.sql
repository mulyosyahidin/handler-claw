/*
  Warnings:

  - A unique constraint covering the columns `[fcm_token]` on the table `user_devices` will be added. If there are existing duplicate values, this will fail.

*/
-- DropIndex
DROP INDEX "user_devices_user_id_device_id_key";

-- CreateIndex
CREATE UNIQUE INDEX "user_devices_fcm_token_key" ON "user_devices"("fcm_token");
