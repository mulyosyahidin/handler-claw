import type { Prisma } from "../../generated/prisma/client.js";
import type { IReminderHook } from "../domain/index.js";

export interface CreateNotificationPayload {
  reminder_hook_id: string;
  user_id: string;
  user_device_id: string;

  title: string;
  body: string;

  data?: Prisma.InputJsonValue | Prisma.NullableJsonNullValueInput | undefined;
}

export interface CreateNotificationResponseData {
  notification: IReminderHook;
}

export interface GetNotificationsResponseData {
  notifications: IReminderHook[];
  meta: {
    page: number;
    per_page: number;
    total: number;
    total_pages: number;
  };
}

export interface NotificationsSummaryData {
  total: number;
  status_counts: {
    received: number;
    processing: number;
    processed: number;
    failed: number;
  };
}
