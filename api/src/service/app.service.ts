import type { HealthCheckData } from "../lib/types/data/health.type.js";
import { createSuccessResponse, type SuccessResponse } from "../lib/types/response.js";
import { prisma } from "../config/index.js";

export class AppService {
  async healthCheck(): Promise<SuccessResponse<HealthCheckData>> {
    const dbStatus = await this.checkDatabase();

    return createSuccessResponse("OK", {
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      database: dbStatus,
    });
  }

  private async checkDatabase(): Promise<"connected" | "disconnected"> {
    try {
      await prisma.$queryRaw`SELECT 1`;
      return "connected";
    } catch {
      return "disconnected";
    }
  }
}
