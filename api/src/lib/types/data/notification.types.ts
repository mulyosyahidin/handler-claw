import type { Prisma } from "../../generated/prisma/client.js";
import type { INotificationHook } from "../domain/index.js";

export interface CreateNotificationPayload {
  reminder_hook_id: string;
  user_id: string;
  user_device_id: string;

  title: string;
  body: string;

  data?: Prisma.InputJsonValue | Prisma.NullableJsonNullValueInput | undefined;
}

export interface CreateNotificationResponseData {
  notification: INotificationHook;
}

export interface GetNotificationsResponseData {
  notifications: INotificationHook[];
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
