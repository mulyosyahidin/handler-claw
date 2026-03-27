import type {
  Prisma,
  NotificationStatus,
  ReminderHookStatus,
} from "../../../../lib/generated/prisma/client.js";
import type { ReminderHook } from "../../domain/entities/notification.entity.js";

/**
 * Request Contracts
 */
export type CreateNotificationRequest = {
  event_id: string;
  type: string;
  title: string;
  message: string;
  meta?: Record<string, unknown> | undefined;
  link_to?: string | undefined;
};

export type GetNotificationsQuery = {
  page: number;
  per_page: number;
  status?: ReminderHookStatus | undefined;
  event_id?: string | undefined;
};

export type NotificationFilter = {
  status?: NotificationStatus | undefined;
};

export type ReminderHookFilter = {
  status?: ReminderHookStatus | undefined;
  event_id?: string | undefined;
};

export type GetNotificationParams = {
  id: string;
};

export type CreateNotificationPayload = {
  reminder_hook_id: string;
  user_id: string;
  user_device_id: string;
  title: string;
  body: string;
  data?: Prisma.InputJsonValue | Prisma.NullableJsonNullValueInput | undefined;
};

export type UpsertReminderHookPayload = {
  id?: string;
  userId: string;
  eventId: string;
  payloadJson: unknown;
  headersJson?: unknown;
  status: string;
};

/**
 * Response Contracts
 */
export type CreateNotificationResponse = {
  notification: ReminderHook;
};

export type GetNotificationsResponse = {
  notifications: ReminderHook[];
  meta: {
    page: number;
    per_page: number;
    total: number;
    total_pages: number;
  };
};

export type GetNotificationDetailResponse = {
  notification: ReminderHook;
};

export type CreateNotificationHookResponse = {
  reminder_hook: ReminderHook;
  notifications_count: number;
};

export type SendNotificationResponse = {
  success: boolean;
  message_id: string | null;
};

export type NotificationsSummary = {
  total: number;
  status_counts: {
    received: number;
    processing: number;
    processed: number;
    failed: number;
  };
};

export type GetNotificationsSummaryResponse = NotificationsSummary;

export type NotificationStatusSummaryData = {
  status: NotificationStatus;
  _count: {
    id: number;
  };
};

export type ReminderHookStatusSummaryData = {
  status: ReminderHookStatus;
  _count: {
    id: number;
  };
};
