import type { NotificationRepository } from "../../domain/repositories/notification.repository.interface.js";
import type {
  ReminderHookFilter,
  GetNotificationsSummaryResponse,
} from "../dtos/notification.dto.js";

export class GetNotificationsSummaryUseCase {
  constructor(private notificationRepository: NotificationRepository) {}

  async execute(
    userId: string,
    filter: ReminderHookFilter = {},
  ): Promise<GetNotificationsSummaryResponse> {
    const counts = await this.notificationRepository.getHooksSummary(userId, filter);

    const status_counts = {
      received: 0,
      processing: 0,
      processed: 0,
      failed: 0,
    };

    let total = 0;

    for (const item of counts) {
      const count = item._count?.id || 0;
      total += count;

      const status = item.status;
      if (status === "RECEIVED") status_counts.received = count;
      else if (status === "PROCESSING") status_counts.processing = count;
      else if (status === "PROCESSED") status_counts.processed = count;
      else if (status === "FAILED") status_counts.failed = count;
    }

    return {
      total,
      status_counts,
    };
  }
}
