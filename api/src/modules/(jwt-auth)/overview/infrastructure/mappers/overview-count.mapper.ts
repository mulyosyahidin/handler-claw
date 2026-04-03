import type { IOverviewCount } from "../../domain/entities/overview-count.entity.js";

export function toOverviewCountEntity(data: {
  whatsapp_message: number;
  prayer_log: number;
  notification_webhook: number;
  notification: number;
  device: number;
  api_key: number;
}): IOverviewCount {
  return {
    whatsapp_message: data.whatsapp_message,
    prayer_log: data.prayer_log,
    notification_webhook: data.notification_webhook,
    notification: data.notification,
    device: data.device,
    api_key: data.api_key,
  };
}
