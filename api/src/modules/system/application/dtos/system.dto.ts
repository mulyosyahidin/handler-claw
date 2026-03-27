/**
 * Response Contracts
 */
export type HealthCheckResponse = {
  timestamp: string;
  uptime: number;
  database: "connected" | "disconnected";
};

export type SystemOverviewCount = {
  total_whatsapp_logs: number;
  total_prayer_logs: number;
  total_reminder_hooks: number;
  total_devices: number;
};

export type GetSystemOverviewResponse = {
  count: SystemOverviewCount;
};
