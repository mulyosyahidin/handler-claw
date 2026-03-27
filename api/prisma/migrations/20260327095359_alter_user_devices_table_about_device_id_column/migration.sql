/*
  Warnings:

  - A unique constraint covering the columns `[device_id]` on the table `user_devices` will be added. If there are existing duplicate values, this will fail.

*/
-- DropIndex
DROP INDEX "user_devices_fcm_token_key";

-- CreateIndex
CREATE UNIQUE INDEX "user_devices_device_id_key" ON "user_devices"("device_id");
