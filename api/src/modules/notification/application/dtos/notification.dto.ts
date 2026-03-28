import type { NotificationStatus } from "../../../../lib/generated/prisma/enums.js";
import type { PaginationMetaDto } from "../../../../lib/types/pagination-meta-dto.js";
import type { INotification } from "../../domain/entities/notification.entity.js";

/**
 * Input Data Contracts
 */
export type CreateNotificationData = {
  notificationWebhookId: string;
  userId: string;
  userDeviceId: string;
  title: string;
  body: string;
  status: "PENDING" | "SENT" | "FAILED";
  retryCount: number;
  data?: Record<string, any>;
};

export type UpdateNotificationData = {
  status?: NotificationStatus;
  retryCount?: number;
  triggeredAt?: Date | null;
  sentAt?: Date | null;
  failedAt?: Date | null;
  fcmMessageId?: string | null;
  errorMessage?: string | null;
  data?: Record<string, any>;
};

export type GetNotificationsQuery = {
  page: number;
  per_page: number;
  status?: NotificationStatus | undefined;
  search?: string | undefined;
};

/**
 * Filter Contracts
 */
export type NotificationFilter = {
  status?: NotificationStatus;
  search?: string;
};

/**
 * Response Contracts
 */
export type CreateNotificationResponse = {
  notification: INotification;
};

export type GetNotificationsResponse = {
  notifications: INotification[];
  meta: PaginationMetaDto;
};

export type GetNotificationDetailResponse = {
  notification: INotification;
};

export type SendNotificationResponse = {
  success: boolean;
  message_id: string | null;
};
