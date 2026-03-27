import type { NotificationRepository } from "../../domain/repositories/notification.repository.interface.js";
import type { GetNotificationDetailResponse } from "../dtos/notification.dto.js";

export class GetNotificationDetailUseCase {
  constructor(private notificationRepository: NotificationRepository) {}

  async execute(userId: string, id: string): Promise<GetNotificationDetailResponse> {
    const hook = await this.notificationRepository.findHookById(userId, id);

    if (!hook) {
      throw new Error("Notification not found");
    }

    return {
      notification: hook,
    };
  }
}
