import logger from "../config/logger.js";
import prisma from "../config/prisma.js";
import { getFirebaseAdmin } from "../lib/firebase-admin.js";
import {
  NotificationStatus,
  type Notification,
  type UserDevice,
} from "../lib/generated/prisma/client.js";
import type { CreateNotificationPayload } from "../lib/types/index.js";
import { toFcmData } from "../utils/utils.js";

export class NotificationService {
  async create(payload: CreateNotificationPayload): Promise<Notification> {
    const { reminder_hook_id, user_id, user_device_id, title, body, data } = payload;

    return prisma.notification.create({
      data: {
        reminderHookId: reminder_hook_id,
        userId: user_id,
        userDeviceId: user_device_id,
        title,
        body,
        ...(data !== undefined && { data }),
      },
    });
  }

  async sendNotification(notification: Notification): Promise<void> {
    try {
      await prisma.notification.update({
        where: {
          id: notification.id,
        },
        data: {
          triggeredAt: new Date(),
          retryCount: notification.retryCount + 1,
        },
      });

      const userDevice = await prisma.userDevice.findUnique({
        where: {
          id: notification.userDeviceId,
        },
      });

      if (!userDevice) {
        throw new Error("Device not found");
      }

      await this.sendToDevice(notification, userDevice);
    } catch (error) {
      const message = error instanceof Error ? error.message : "Unknown error";

      await prisma.notification.update({
        where: {
          id: notification.id,
        },
        data: {
          status: NotificationStatus.FAILED,
          failedAt: new Date(),
          errorMessage: message,
        },
      });
    }
  }

  /**
   * Kirim notifikasi ke satu device
   */
  private async sendToDevice(notification: Notification, userDevice: UserDevice): Promise<void> {
    const message = {
      token: userDevice.fcmToken,
      notification: {
        title: notification.title,
        body: notification.body,
      },
      data: toFcmData(notification.data),
      android: {
        priority: "high" as const,
        notification: {
          channelId: "default_channel",
          priority: "high" as const,
          defaultSound: true,
          defaultVibrateTimings: true,
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    };

    try {
      const firebaseAdmin = getFirebaseAdmin();
      const messageId = await firebaseAdmin.messaging().send(message);

      await prisma.notification.update({
        where: {
          id: notification.id,
        },
        data: {
          fcmMessageId: messageId,
          status: NotificationStatus.SENT,
          sentAt: new Date(),
        },
      });
    } catch (error: any) {
      if (
        error.code === "messaging/registration-token-not-registered" ||
        error.code === "messaging/invalid-registration-token"
      ) {
        logger.warn(`[Notification] Token invalid, menghapus device ${userDevice.id}`);
        await prisma.userDevice.update({
          where: {
            id: userDevice.id,
          },
          data: {
            status: "INVALID_TOKEN",
          },
        });
      }
      throw error;
    }
  }
}

export const notificationService = new NotificationService();
