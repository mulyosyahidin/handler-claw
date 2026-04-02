import type { HealthRepository } from "../../domain/repositories/health.repository.interface.js";
import type { HealthCheckResponse } from "../dtos/system.dto.js";

export class HealthCheckUseCase {
  constructor(private healthRepository: HealthRepository) {}

  async execute(): Promise<HealthCheckResponse> {
    const dbStatus = await this.healthRepository.checkDatabaseConnection();

    return {
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      database: dbStatus,
    };
  }
}
