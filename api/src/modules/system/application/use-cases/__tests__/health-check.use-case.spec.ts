import { describe, it, expect, vi, beforeEach } from "vitest";
import { HealthCheckUseCase } from "../health-check.use-case.js";
import type { HealthRepository } from "../../../domain/repositories/health.repository.interface.js";

describe("HealthCheckUseCase", () => {
  let healthCheckUseCase: HealthCheckUseCase;
  let mockHealthRepository: HealthRepository;

  beforeEach(() => {
    mockHealthRepository = {
      checkDatabaseConnection: vi.fn(),
    };

    healthCheckUseCase = new HealthCheckUseCase(mockHealthRepository);
  });

  it("should return health status successfully", async () => {
    vi.mocked(mockHealthRepository.checkDatabaseConnection).mockResolvedValue("connected");

    const result = await healthCheckUseCase.execute();

    expect(result.database).toBe("connected");
    expect(result.timestamp).toBeDefined();
    expect(result.uptime).toBeGreaterThan(0);
  });

  it("should return disconnected if database check fails", async () => {
    vi.mocked(mockHealthRepository.checkDatabaseConnection).mockResolvedValue("disconnected");

    const result = await healthCheckUseCase.execute();

    expect(result.database).toBe("disconnected");
  });
});
