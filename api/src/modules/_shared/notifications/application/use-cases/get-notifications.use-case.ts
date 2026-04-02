import { NotificationStatus } from "../../../../../lib/generated/prisma/enums.js";
import type { NotificationRepository } from "../../domain/repositories/notification.repository.interface.js";
import { toNotificationEntity } from "../../infrastructure/mappers/notification.mapper.js";
import type {
  GetNotificationsQuery,
  GetNotificationsResponse,
  NotificationFilter,
} from "../dtos/notification.dto.js";

export class GetNotificationsUseCase {
  constructor(private notificationRepository: NotificationRepository) {}

  async execute(userId: string, query: GetNotificationsQuery): Promise<GetNotificationsResponse> {
    const { status, page, per_page, search } = query;

    const effectiveStatus = status ?? NotificationStatus.SENT;

    const skip = (page - 1) * per_page;
    const take = per_page;

    const normalizedSearch = search?.trim();

    const filter: NotificationFilter = {
      status: effectiveStatus,
      ...(normalizedSearch && { search: normalizedSearch }),
    };

    const { notifications, total } = await this.notificationRepository.findAll(userId, filter, {
      skip,
      take,
    });

    return {
      notifications: notifications.map(toNotificationEntity),
      meta: {
        page,
        per_page,
        total,
        total_pages: Math.ceil(total / per_page),
      },
    };
  }
}
