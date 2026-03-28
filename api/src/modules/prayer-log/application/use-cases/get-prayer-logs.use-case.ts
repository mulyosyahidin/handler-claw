import type { GetPrayerLogsQuery, GetPrayerLogsResponse } from "../dtos/prayer-log.dto.js";
import type { PrayerLogRepository } from "../../domain/repositories/prayer-log.repository.interface.js";
import { getPrayerDateFilter } from "../../../../utils/date-filter.js";
import { toPrayerLogEntity } from "../../infrastructure/mappers/prayer-log.mapper.js";

export class GetPrayerLogsUseCase {
  constructor(private prayerLogRepository: PrayerLogRepository) {}

  async execute(userId: string, query: GetPrayerLogsQuery): Promise<GetPrayerLogsResponse> {
    const { date_type, start, end, page, per_page } = query;

    const safePage = Math.max(page, 1);
    const safePerPage = Math.max(per_page, 1);

    const { filter: dateFilter, date_start, date_end } = getPrayerDateFilter(date_type, start, end);

    const skip = (safePage - 1) * safePerPage;
    const take = safePerPage;

    const { logs, total } = await this.prayerLogRepository.findAll(userId, dateFilter, {
      skip,
      take,
    });

    return {
      filter: {
        date_type,
        ...(date_type === "custom" ? { start, end } : {}),
        ...(date_start && date_end
          ? {
              filtered: {
                date_start,
                date_end,
              },
            }
          : {}),
      },
      prayer_logs: logs.map(toPrayerLogEntity),
      meta: {
        page: safePage,
        per_page: safePerPage,
        total,
        total_pages: Math.ceil(total / safePerPage),
      },
    };
  }
}
