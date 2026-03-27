import { prisma } from "../../../../config/index.js";
import type { HealthRepository } from "../../domain/repositories/health.repository.interface.js";

export class PrismaHealthRepository implements HealthRepository {
  async checkDatabaseConnection(): Promise<"connected" | "disconnected"> {
    try {
      await prisma.$queryRaw`SELECT 1`;
      return "connected";
    } catch {
      return "disconnected";
    }
  }
}
