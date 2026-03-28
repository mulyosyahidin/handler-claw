import type { IOverviewCount } from "../../domain/entities/overview-count.entity.js";

export function toOverviewCountEntity(data: {
  whatsapp_log: number;
  prayer_log: number;
  notification_webhook: number;
  notification: number;
  device: number;
}): IOverviewCount {
  return {
    whatsapp_log: data.whatsapp_log,
    prayer_log: data.prayer_log,
    notification_webhook: data.notification_webhook,
    notification: data.notification,
    device: data.device,
  };
}
