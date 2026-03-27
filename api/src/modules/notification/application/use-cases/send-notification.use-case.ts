import type { NotificationRepository } from "../../domain/repositories/notification.repository.interface.js";
import type { NotificationSender } from "../../domain/services/notification-sender.service.interface.js";
import type { UserDeviceRepository } from "../../../user-device/domain/repositories/user-device.repository.interface.js";
import type { SendNotificationResponse } from "../dtos/notification.dto.js";
import { NotificationStatus, UserDeviceStatus } from "../../../../lib/generated/prisma/client.js";
import logger from "../../../../config/logger.js";

export class SendNotificationUseCase {
  constructor(
    private notificationRepository: NotificationRepository,
    private userDeviceRepository: UserDeviceRepository,
    private notificationSender: NotificationSender,
  ) {}

  async execute(notificationId: string): Promise<SendNotificationResponse> {
    const notification = await this.notificationRepository.findNotificationById(notificationId);
    if (!notification) {
      throw new Error("Notification not found");
    }

    try {
      await this.notificationRepository.updateNotification(notification.id, {
        triggeredAt: new Date(),
        retryCount: { increment: 1 },
      });

      const userDevice = await this.userDeviceRepository.findById(
        notification.user_id,
        notification.user_device_id,
      );

      if (!userDevice) {
        throw new Error("Device not found or not owned by user");
      }

      try {
        const fcmMessageId = await this.notificationSender.sendToDevice(notification, userDevice);

        await this.notificationRepository.updateNotification(notification.id, {
          fcmMessageId,
          status: NotificationStatus.SENT,
          sentAt: new Date(),
        });

        await this.notificationRepository.updateHookStatus(
          notification.reminder_hook_id,
          "PROCESSED",
        );

        return { success: true, message_id: fcmMessageId };
      } catch (error: unknown) {
        const errorMessage = error instanceof Error ? error.message : "Unknown error";
        logger.error(
          `[Notification] Failed to send notification ${notification.id}:`,
          errorMessage,
        );

        // Handle invalid token
        const errorWithCode = error as { code?: string };
        if (
          errorWithCode.code === "messaging/registration-token-not-registered" ||
          errorWithCode.code === "messaging/invalid-registration-token"
        ) {
          await this.userDeviceRepository.updateStatus(
            notification.user_id,
            userDevice.fcm_token,
            UserDeviceStatus.INVALID_TOKEN,
          );
        }

        await this.notificationRepository.updateNotification(notification.id, {
          status: NotificationStatus.FAILED,
          failedAt: new Date(),
          errorMessage,
        });

        await this.notificationRepository.updateHookStatus(
          notification.reminder_hook_id,
          "FAILED",
          errorMessage,
        );

        throw error;
      }
    } catch (error) {
      logger.error(`[Notification] Orchestration error for ${notificationId}:`, error);

      throw error;
    }
  }
}
