import prisma from "../../../../../config/prisma.js";
import type { NotificationWebhook } from "../../../../../lib/generated/prisma/client.js";
import type {
  CreateNotificationWebhookData,
  UpdateNotificationWebhookData,
} from "../../application/dtos/notification-webhook.dto.js";
import type { NotificationWebhookRepository } from "../../domain/repositories/notification-webhook.repository.interface.js";

export class PrismaNotificationWebhookRepository implements NotificationWebhookRepository {
  async create(userId: string, data: CreateNotificationWebhookData): Promise<NotificationWebhook> {
    return prisma.notificationWebhook.create({
      data: {
        userId,
        content: data,
      },
    });
  }

  async update(id: string, data: UpdateNotificationWebhookData): Promise<NotificationWebhook> {
    return prisma.notificationWebhook.update({
      where: { id },
      data: data as any,
    });
  }
}
