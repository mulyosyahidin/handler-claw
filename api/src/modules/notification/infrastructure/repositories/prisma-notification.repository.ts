import { prisma } from "../../../../config/index.js";
import {
  type Prisma,
  NotificationStatus,
  ReminderHookStatus,
} from "../../../../lib/generated/prisma/client.js";
import type { Notification, ReminderHook } from "../../domain/entities/notification.entity.js";
import type { NotificationRepository } from "../../domain/repositories/notification.repository.interface.js";
import type {
  UpsertReminderHookPayload,
  NotificationStatusSummaryData,
  ReminderHookStatusSummaryData,
  NotificationFilter,
  ReminderHookFilter,
  GetNotificationsQuery,
} from "../../application/dtos/notification.dto.js";
import { toNotificationEntity, toReminderHookEntity } from "../mappers/notification.mapper.js";

export class PrismaNotificationRepository implements NotificationRepository {
  async upsertHook(data: UpsertReminderHookPayload): Promise<ReminderHook> {
    const hook = await prisma.reminderHook.upsert({
      where: {
        userId_eventId: {
          userId: data.userId,
          eventId: data.eventId,
        },
      },
      update: {
        payloadJson: data.payloadJson as Prisma.InputJsonValue,
        headersJson: data.headersJson as Prisma.InputJsonValue,
        status: data.status as ReminderHookStatus,
        updatedAt: new Date(),
      },
      create: {
        ...(data.id ? { id: data.id } : {}),
        userId: data.userId,
        eventId: data.eventId,
        payloadJson: data.payloadJson as Prisma.InputJsonValue,
        headersJson: data.headersJson as Prisma.InputJsonValue,
        status: data.status as ReminderHookStatus,
      },
    });

    return toReminderHookEntity(hook);
  }

  async createNotification(data: Prisma.NotificationUncheckedCreateInput): Promise<Notification> {
    const notification = await prisma.notification.create({ data });

    return toNotificationEntity(notification);
  }

  async updateNotification(
    id: string,
    data: Prisma.NotificationUncheckedUpdateInput,
  ): Promise<Notification> {
    const updated = await prisma.notification.update({
      where: { id },
      data: {
        ...data,
        updatedAt: new Date(),
      },
    });

    return toNotificationEntity(updated);
  }

  async updateHookStatus(
    id: string,
    status: ReminderHookStatus,
    errorMessage?: string | null,
  ): Promise<ReminderHook> {
    const updated = await prisma.reminderHook.update({
      where: { id },
      data: {
        status,
        errorMessage: errorMessage ?? null,
        ...(status === "PROCESSED" || status === "FAILED" ? { processedAt: new Date() } : {}),
        updatedAt: new Date(),
      },
    });

    return toReminderHookEntity(updated);
  }

  async findNotificationById(id: string): Promise<Notification | null> {
    const notification = await prisma.notification.findUnique({
      where: { id },
    });

    return notification ? toNotificationEntity(notification) : null;
  }

  async findHookById(userId: string, id: string): Promise<ReminderHook | null> {
    const hook = await prisma.reminderHook.findFirst({
      where: { id, userId },
      include: { notifications: true },
    });

    return hook ? toReminderHookEntity(hook) : null;
  }

  async findNotificationsSummary(
    userId: string,
    filter: NotificationFilter,
  ): Promise<NotificationStatusSummaryData[]> {
    const where: Prisma.NotificationWhereInput = { userId };
    if (filter.status) where.status = filter.status as NotificationStatus;

    const result = await prisma.notification.groupBy({
      by: ["status"],
      where,
      _count: { id: true },
    });

    return (result as unknown as { status: NotificationStatus; _count: { id: number } }[]).map(
      (item) => ({
        status: item.status,
        _count: {
          id: item._count?.id || 0,
        },
      }),
    );
  }

  async getHooksSummary(
    userId: string,
    filter: ReminderHookFilter,
  ): Promise<ReminderHookStatusSummaryData[]> {
    const where: Prisma.ReminderHookWhereInput = { userId };
    if (filter.status) where.status = filter.status as ReminderHookStatus;
    if (filter.event_id) where.eventId = filter.event_id;

    const result = await prisma.reminderHook.groupBy({
      by: ["status"],
      where,
      _count: { id: true },
    });

    return (result as unknown as { status: ReminderHookStatus; _count: { id: number } }[]).map(
      (item) => ({
        status: item.status,
        _count: {
          id: item._count?.id || 0,
        },
      }),
    );
  }

  async findNotificationsByUserId(
    userId: string,
    take: number,
    skip: number,
  ): Promise<{ notifications: Notification[]; total: number }> {
    const [total, notifications] = await Promise.all([
      prisma.notification.count({
        where: { userId },
      }),
      prisma.notification.findMany({
        where: { userId },
        orderBy: { createdAt: "desc" },
        take,
        skip,
      }),
    ]);

    return {
      notifications: notifications.map(toNotificationEntity),
      total,
    };
  }

  async findHooksByUserId(
    userId: string,
    filter: GetNotificationsQuery,
  ): Promise<{ hooks: ReminderHook[]; total: number }> {
    const { page = 1, per_page = 10, ...rest } = filter;
    const skip = (page - 1) * per_page;
    const take = per_page;

    const where: Prisma.ReminderHookWhereInput = { userId };
    if (rest.status) where.status = rest.status;
    if (rest.event_id) where.eventId = rest.event_id;

    const [total, hooks] = await Promise.all([
      prisma.reminderHook.count({
        where,
      }),
      prisma.reminderHook.findMany({
        where,
        orderBy: { createdAt: "desc" },
        take,
        skip,
      }),
    ]);

    return {
      hooks: hooks.map(toReminderHookEntity),
      total,
    };
  }
}
