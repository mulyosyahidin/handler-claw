import type { IOverviewCount } from "../../domain/entities/overview-count.entity.js";

/**
 * Data Contracts
 */
export type OverviewCounts = {
  whatsapp_log: number;
  prayer_log: number;
  notification_webhook: number;
  notification: number;
  device: number;
};

/**
 * Response Contracts
 */
export type GetOverviewResponse = {
  count: IOverviewCount;
};
