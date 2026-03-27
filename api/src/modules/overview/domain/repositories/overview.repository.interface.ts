import type { SystemOverviewCount } from "../../../system/application/dtos/system.dto.js";

export interface OverviewRepository {
  getCounts(userId: string): Promise<SystemOverviewCount>;
}
