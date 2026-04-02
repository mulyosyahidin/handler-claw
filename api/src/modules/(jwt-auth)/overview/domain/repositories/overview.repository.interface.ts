import type { OverviewCounts } from "../../application/dtos/overview.dto.js";

export interface OverviewRepository {
  getUserOverviewCounts(userId: string): Promise<OverviewCounts>;
  getTodayPrayerStatus(userId: string): Promise<Record<string, boolean>>;
}
