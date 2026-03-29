import type { GetOverviewResponse } from "../dtos/overview.dto.js";
import type { OverviewRepository } from "../../domain/repositories/overview.repository.interface.js";
import { toOverviewCountEntity } from "../../infrastructure/mappers/overview-count.mapper.js";

export class GetOverviewUseCase {
  constructor(private overviewRepository: OverviewRepository) {}

  async execute(userId: string): Promise<GetOverviewResponse> {
    const [counts, prayerStatus] = await Promise.all([
      this.overviewRepository.getUserOverviewCounts(userId),
      this.overviewRepository.getTodayPrayerStatus(userId),
    ]);

    return {
      count: toOverviewCountEntity(counts),
      prayer_status: prayerStatus,
    };
  }
}
