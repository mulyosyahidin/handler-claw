import type { NotificationRepository } from "../../domain/repositories/notification.repository.interface.js";
import type { NotificationSender } from "../../domain/services/notification-sender.service.interface.js";
import type { UserDeviceRepository } from "../../../../(jwt-auth)/user-devices/domain/repositories/user-device.repository.interface.js";
import type { SendNotificationResponse } from "../dtos/notification.dto.js";
import {
  NotificationStatus,
  UserDeviceStatus,
} from "../../../../../lib/generated/prisma/client.js";
import logger from "../../../../../config/logger.js";
import type { NotificationWebhookRepository } from "../../domain/repositories/notification-webhook.repository.interface.js";
import { NotFoundError } from "../../../../../lib/errors/not-found.error.js";

export class SendNotificationUseCase {
  constructor(
    private notificationWebhookRepository: NotificationWebhookRepository,
    private notificationRepository: NotificationRepository,
    private userDeviceRepository: UserDeviceRepository,
    private notificationSender: NotificationSender,
  ) {}

  async execute(userId: string, id: string): Promise<SendNotificationResponse> {
    // 1. Ambil notification
    const notification = await this.notificationRepository.findById(userId, id);
    if (!notification) {
      throw new NotFoundError("Notification tidak ditemukan");
    }

    // 2. Ambil device
    const userDevice = await this.userDeviceRepository.findById(
      notification.userId,
      notification.userDeviceId,
    );

    if (!userDevice) {
      throw new NotFoundError("Device tidak ditemukan");
    }

    // 2.1. Pastikan status device ACTIVE
    if (userDevice.status !== UserDeviceStatus.ACTIVE) {
      logger.info(
        `[Notification] Skipping send to ${userDevice.id} because status is ${userDevice.status}`,
      );

      // Update status notification agar tidak menggantung (tergantung kebijakan bisnis,
      // bisa FAILED atau tetap PENDING. Di sini kita anggap FAILED agar tidak dicoba lagi)
      await this.notificationRepository.update(notification.id, {
        status: NotificationStatus.FAILED,
        failedAt: new Date(),
        errorMessage: `Device status is ${userDevice.status}`,
      });

      return {
        success: false,
        message_id: null,
      };
    }

    // 3. Update state awal
    await this.notificationRepository.update(notification.id, {
      triggeredAt: new Date(),
      retryCount: notification.retryCount + 1,
    });

    await this.notificationWebhookRepository.update(notification.notificationWebhookId, {
      status: "PROCESSING",
    });

    try {
      // 4. Kirim notifikasi
      const fcmMessageId = await this.notificationSender.sendToDevice(notification, userDevice);

      // 5. Update sukses
      await this.notificationRepository.update(notification.id, {
        fcmMessageId,
        status: NotificationStatus.SENT,
        sentAt: new Date(),
      });

      return {
        success: true,
        message_id: fcmMessageId,
      };
    } catch (error: any) {
      const errorMessage = error?.message ?? "Unknown error";

      logger.error(`[Notification] Failed to send ${notification.id}:`, errorMessage);

      // Handle invalid token
      if (
        error?.code === "messaging/registration-token-not-registered" ||
        error?.code === "messaging/invalid-registration-token"
      ) {
        try {
          await this.userDeviceRepository.update(userDevice.id, {
            status: UserDeviceStatus.INVALID_TOKEN,
          });
        } catch (e) {
          logger.error("[Notification] Failed update device status:", e);
        }
      }

      // Update gagal
      await this.notificationRepository.update(notification.id, {
        status: NotificationStatus.FAILED,
        failedAt: new Date(),
        errorMessage,
      });

      throw error;
    } finally {
      try {
        await this.notificationWebhookRepository.update(notification.notificationWebhookId, {
          status: "PROCESSED",
        });
      } catch (e) {
        logger.error(
          `[Notification] Failed to mark webhook as PROCESSED (${notification.notificationWebhookId})`,
          e,
        );
      }
    }
  }
}
