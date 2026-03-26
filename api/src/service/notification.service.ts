import logger from "../config/logger.js";
import prisma from "../config/prisma.js";
import { getFirebaseAdmin } from "../lib/firebase-admin.js";
import {
  NotificationStatus,
  type Notification,
  type UserDevice,
  type ReminderHook,
  Prisma,
} from "../lib/generated/prisma/client.js";
import type {
  CreateNotificationPayload,
  GetNotificationsResponseData,
  NotificationsSummaryData,
} from "../lib/types/data/index.js";
import type {
  CreateNotificationInput,
  GetNotificationsQuery,
} from "../lib/schemas/notification.schema.js";
import {
  createErrorResponse,
  createSuccessResponse,
  type SuccessResponse,
} from "../lib/types/response.js";
import { type IReminderHook } from "../lib/types/domain/index.js";
import { toReminderHookEntity } from "../lib/mappers/index.js";
import { extractImportantHeaders, toFcmData } from "../utils/utils.js";

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

  async createNotificationHook(
    userId: string,
    data: CreateNotificationInput,
    headers: Record<string, any>,
  ): Promise<ReminderHook> {
    const headersObject = extractImportantHeaders(headers);

    return await prisma.reminderHook.upsert({
      where: {
        userId_eventId: {
          userId,
          eventId: data.event_id,
        },
      },
      update: {
        payloadJson: data as unknown as Prisma.InputJsonValue,
        headersJson: headersObject,
        status: "RECEIVED",
        errorMessage: null,
      },
      create: {
        userId,
        eventId: data.event_id,
        payloadJson: data as unknown as Prisma.InputJsonValue,
        headersJson: headersObject,
        status: "RECEIVED",
      },
    });
  }

  async getNotifications(
    userId: string,
    query: GetNotificationsQuery,
  ): Promise<SuccessResponse<GetNotificationsResponseData>> {
    const { page, per_page } = query;
    const skip = (page - 1) * per_page;
    const take = per_page;

    const [total, hooks] = await Promise.all([
      prisma.reminderHook.count({ where: { userId } }),
      prisma.reminderHook.findMany({
        where: { userId },
        skip,
        take,
        orderBy: { createdAt: "desc" },
      }),
    ]);

    return createSuccessResponse("Berhasil mengambil daftar notifikasi", {
      notifications: hooks.map(toReminderHookEntity),
      meta: {
        page,
        per_page,
        total,
        total_pages: Math.ceil(total / per_page),
      },
    });
  }

  async getNotificationsSummary(
    userId: string,
  ): Promise<SuccessResponse<NotificationsSummaryData>> {
    const counts = await prisma.reminderHook.groupBy({
      by: ["status"],
      where: { userId },
      _count: { _all: true },
    });

    const status_counts = {
      received: 0,
      processing: 0,
      processed: 0,
      failed: 0,
    };

    let total = 0;

    for (const item of counts) {
      const count = item._count._all;
      total += count;

      if (item.status === "RECEIVED") status_counts.received = count;
      else if (item.status === "PROCESSING") status_counts.processing = count;
      else if (item.status === "PROCESSED") status_counts.processed = count;
      else if (item.status === "FAILED") status_counts.failed = count;
    }

    return createSuccessResponse("Berhasil mengambil summary notifikasi", {
      total,
      status_counts,
    });
  }

  async getNotificationDetails(
    userId: string,
    id: string,
  ): Promise<SuccessResponse<{ notification: IReminderHook }>> {
    const hook = await prisma.reminderHook.findFirst({
      where: { id, userId },
    });

    if (!hook) {
      throw createErrorResponse("Not Found", { id: "Notifikasi tidak ditemukan" });
    }

    return createSuccessResponse("Berhasil mengambil detail notifikasi", {
      notification: toReminderHookEntity(hook),
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

      await prisma.reminderHook.update({
        where: {
          id: notification.reminderHookId,
        },
        data: {
          status: "PROCESSING",
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

      await prisma.reminderHook.update({
        where: {
          id: notification.reminderHookId,
        },
        data: {
          status: "FAILED",
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

      await prisma.reminderHook.update({
        where: {
          id: notification.reminderHookId,
        },
        data: {
          status: "PROCESSED",
          processedAt: new Date(),
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

      await prisma.notification.update({
        where: {
          id: notification.id,
        },
        data: {
          status: NotificationStatus.FAILED,
          failedAt: new Date(),
          errorMessage: error.message,
        },
      });

      await prisma.reminderHook.update({
        where: {
          id: notification.reminderHookId,
        },
        data: {
          status: "FAILED",
          errorMessage: error.message,
        },
      });
    }
  }
}

export const notificationService = new NotificationService();
