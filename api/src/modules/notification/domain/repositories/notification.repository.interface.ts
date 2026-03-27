import { type Prisma, ReminderHookStatus } from "../../../../lib/generated/prisma/client.js";
import type { Notification, ReminderHook } from "../entities/notification.entity.js";
import type {
  UpsertReminderHookPayload,
  NotificationStatusSummaryData,
  ReminderHookStatusSummaryData,
  NotificationFilter,
  ReminderHookFilter,
  GetNotificationsQuery,
} from "../../application/dtos/notification.dto.js";

export interface NotificationRepository {
  upsertHook(data: UpsertReminderHookPayload): Promise<ReminderHook>;
  createNotification(data: Prisma.NotificationUncheckedCreateInput): Promise<Notification>;
  updateNotification(
    id: string,
    data: Prisma.NotificationUncheckedUpdateInput,
  ): Promise<Notification>;
  updateHookStatus(
    id: string,
    status: ReminderHookStatus,
    errorMessage?: string | null,
  ): Promise<ReminderHook>;
  findNotificationById(id: string): Promise<Notification | null>;
  findHookById(userId: string, id: string): Promise<ReminderHook | null>;
  findNotificationsSummary(
    userId: string,
    filter: NotificationFilter,
  ): Promise<NotificationStatusSummaryData[]>;
  getHooksSummary(
    userId: string,
    filter: ReminderHookFilter,
  ): Promise<ReminderHookStatusSummaryData[]>;
  findNotificationsByUserId(
    userId: string,
    take: number,
    skip: number,
  ): Promise<{ notifications: Notification[]; total: number }>;
  findHooksByUserId(
    userId: string,
    filter: GetNotificationsQuery,
  ): Promise<{ hooks: ReminderHook[]; total: number }>;
}
