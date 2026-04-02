import { NotFoundError } from "../../../../../lib/errors/not-found.error.js";
import type { NotificationRepository } from "../../domain/repositories/notification.repository.interface.js";
import { toNotificationEntity } from "../../infrastructure/mappers/notification.mapper.js";
import type { GetNotificationDetailResponse } from "../dtos/notification.dto.js";

export class GetNotificationDetailUseCase {
  constructor(private notificationRepository: NotificationRepository) {}

  async execute(userId: string, id: string): Promise<GetNotificationDetailResponse> {
    const notification = await this.notificationRepository.findById(userId, id);

    if (!notification) {
      throw new NotFoundError("Notification not found");
    }

    return {
      notification: toNotificationEntity(notification),
    };
  }
}
