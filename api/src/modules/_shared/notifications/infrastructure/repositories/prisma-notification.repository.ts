import { prisma } from "../../../../../config/index.js";
import { type Notification, type Prisma } from "../../../../../lib/generated/prisma/client.js";
import type { PaginationType } from "../../../../../lib/types/pagination.type.js";
import type {
  CreateNotificationData,
  NotificationFilter,
  UpdateNotificationData,
} from "../../application/dtos/notification.dto.js";
import type { NotificationRepository } from "../../domain/repositories/notification.repository.interface.js";

export class PrismaNotificationRepository implements NotificationRepository {
  async create(data: CreateNotificationData): Promise<Notification> {
    return prisma.notification.create({
      data: {
        notificationWebhookId: data.notificationWebhookId,
        userId: data.userId,
        userDeviceId: data.userDeviceId,
        title: data.title,
        body: data.body,
        status: data.status,
        retryCount: data.retryCount,

        ...(data.data !== undefined && {
          data: data.data as Prisma.InputJsonValue,
        }),
      },
    });
  }

  async update(id: string, data: UpdateNotificationData): Promise<Notification> {
    return prisma.notification.update({
      where: { id },
      data: {
        ...(data.status !== undefined ? { status: data.status } : {}),
        ...(data.retryCount !== undefined ? { retryCount: data.retryCount } : {}),
        ...(data.triggeredAt !== undefined ? { triggeredAt: data.triggeredAt } : {}),
        ...(data.sentAt !== undefined ? { sentAt: data.sentAt } : {}),
        ...(data.failedAt !== undefined ? { failedAt: data.failedAt } : {}),
        ...(data.fcmMessageId !== undefined ? { fcmMessageId: data.fcmMessageId } : {}),
        ...(data.errorMessage !== undefined ? { errorMessage: data.errorMessage } : {}),
        ...(data.data !== undefined ? { data: data.data as Prisma.InputJsonValue } : {}),
        updatedAt: new Date(),
      },
    });
  }

  async findById(userId: string, id: string): Promise<Notification | null> {
    return prisma.notification.findFirst({
      where: { id, userId },
    });
  }

  async findAll(
    userId: string,
    filter: NotificationFilter,
    pagination: PaginationType,
  ): Promise<{ notifications: Notification[]; total: number }> {
    const { skip, take } = pagination;
    const { status, search } = filter;

    const where: Prisma.NotificationWhereInput = {
      userId,
      ...(status !== undefined ? { status } : {}),
      ...(search && {
        OR: [
          { title: { contains: search, mode: "insensitive" } },
          { body: { contains: search, mode: "insensitive" } },
        ],
      }),
    };

    const [total, notifications] = await Promise.all([
      prisma.notification.count({ where }),
      prisma.notification.findMany({
        where,
        orderBy: { createdAt: "desc" },
        skip,
        take,
      }),
    ]);

    return {
      notifications,
      total,
    };
  }
}
