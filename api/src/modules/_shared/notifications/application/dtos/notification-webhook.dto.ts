import type { NotificationWebhookStatus } from "../../../../../lib/generated/prisma/enums.js";
import type { INotificationWebhook } from "../../domain/entities/notification-webhook.entity.js";
import type { INotification } from "../../domain/entities/notification.entity.js";

/**
 * Input Data Contracts
 */
export type CreateNotificationWebhookData = {
  title: string;
  message: string;
  meta?: Record<string, any> | undefined;
};

export type UpdateNotificationWebhookData = {
  content?: Record<string, any> | undefined;
  status?: NotificationWebhookStatus | undefined;
};

export type CreateNotificationWebhookRequest = {
  title: string;
  message: string;
  meta?: Record<string, any> | undefined;
};

/**
 * Response Contracts
 */
export type CreateNotificationHookResponse = {
  notification_webhook: INotificationWebhook;
  notifications: {
    count: number;
    items: INotification[];
  };
};
