/**
 * Response Contracts
 */
export type HealthCheckResponse = {
  timestamp: string;
  uptime: number;
  database: "connected" | "disconnected";
};
