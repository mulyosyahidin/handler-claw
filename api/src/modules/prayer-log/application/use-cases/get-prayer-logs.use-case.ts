import type { GetPrayerLogsQuery, GetPrayerLogsResponse } from "../dtos/prayer-log.dto.js";
import type { PrayerLogRepository } from "../../domain/repositories/prayer-log.repository.interface.js";
import { getPrayerDateFilter } from "../../../../utils/date-filter.js";

export class GetPrayerLogsUseCase {
  constructor(private prayerLogRepository: PrayerLogRepository) {}

  async execute(userId: string, query: GetPrayerLogsQuery): Promise<GetPrayerLogsResponse> {
    const { date_type, start, end, page, per_page } = query;
    const { filter: dateFilter, date_start, date_end } = getPrayerDateFilter(date_type, start, end);

    const { logs, total } = await this.prayerLogRepository.findMany(
      userId,
      dateFilter,
      per_page,
      (page - 1) * per_page,
    );

    return {
      filter: {
        date_type,
        ...(date_type === "custom" ? { start, end } : {}),
        filtered: {
          date_start,
          date_end,
        },
      },
      prayer_logs: logs,
      meta: {
        page,
        per_page,
        total,
        total_pages: Math.ceil(total / per_page),
      },
    };
  }
}
