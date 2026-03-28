import { type Notification } from "../../../../lib/generated/prisma/client.js";
import type { PaginationType } from "../../../../lib/types/pagination.type.js";
import type {
  CreateNotificationData,
  NotificationFilter,
  UpdateNotificationData,
} from "../../application/dtos/notification.dto.js";

export interface NotificationRepository {
  create(data: CreateNotificationData): Promise<Notification>;
  update(id: string, data: UpdateNotificationData): Promise<Notification>;
  findById(userId: string, id: string): Promise<Notification | null>;
  findAll(
    userId: string,
    filter: NotificationFilter,
    pagination: PaginationType,
  ): Promise<{ notifications: Notification[]; total: number }>;
}
