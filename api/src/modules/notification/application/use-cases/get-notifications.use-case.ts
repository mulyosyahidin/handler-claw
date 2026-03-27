import type { NotificationRepository } from "../../domain/repositories/notification.repository.interface.js";
import type { GetNotificationsQuery, GetNotificationsResponse } from "../dtos/notification.dto.js";

export class GetNotificationsUseCase {
  constructor(private notificationRepository: NotificationRepository) {}

  async execute(userId: string, query: GetNotificationsQuery): Promise<GetNotificationsResponse> {
    const { hooks, total } = await this.notificationRepository.findHooksByUserId(userId, query);

    return {
      notifications: hooks,
      meta: {
        page: query.page,
        per_page: query.per_page,
        total,
        total_pages: Math.ceil(total / query.per_page),
      },
    };
  }
}
