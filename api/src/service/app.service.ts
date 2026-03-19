import type { HealthCheckData } from "@/lib/types/data/app.type";
import { createSuccessResponse, type SuccessResponse } from "@/lib/types/response";

export class AppService {
  async healthCheck(): Promise<SuccessResponse<HealthCheckData>> {
    return createSuccessResponse("OK", {
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      database: "connected",
    });
  }
}
