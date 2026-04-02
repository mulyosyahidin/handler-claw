-- CreateEnum
CREATE TYPE "PrayerCategory" AS ENUM ('WAJIB', 'SUNNAH');

-- CreateEnum
CREATE TYPE "PrayerType" AS ENUM ('SUBUH', 'DZUHUR', 'ASHAR', 'MAGHRIB', 'ISYA', 'JUMAT', 'DHUHA', 'TAHAJUD', 'WITIR');

-- CreateEnum
CREATE TYPE "PrayerMethod" AS ENUM ('JAMAAH', 'SENDIRI');

-- CreateEnum
CREATE TYPE "PrayerPlace" AS ENUM ('MASJID', 'RUMAH', 'LAINNYA');

-- CreateTable
CREATE TABLE "prayer_logs" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "date" DATE NOT NULL,
    "prayer" "PrayerType" NOT NULL,
    "category" "PrayerCategory" NOT NULL,
    "performed" BOOLEAN NOT NULL DEFAULT false,
    "performed_at" TIMESTAMP(3),
    "method" "PrayerMethod",
    "place" "PrayerPlace",
    "is_qadha" BOOLEAN NOT NULL DEFAULT false,
    "notes" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "prayer_logs_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "prayer_logs_user_id_date_idx" ON "prayer_logs"("user_id", "date");

-- AddForeignKey
ALTER TABLE "prayer_logs" ADD CONSTRAINT "prayer_logs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
