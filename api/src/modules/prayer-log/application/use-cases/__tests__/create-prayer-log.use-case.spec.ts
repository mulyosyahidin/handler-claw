import { describe, it, expect, vi, beforeEach } from "vitest";
import { CreatePrayerLogUseCase } from "../create-prayer-log.use-case.js";
import type { PrayerLogRepository } from "../../../domain/repositories/prayer-log.repository.interface.js";

describe("CreatePrayerLogUseCase", () => {
  let createPrayerLogUseCase: CreatePrayerLogUseCase;
  let mockPrayerLogRepository: PrayerLogRepository;

  beforeEach(() => {
    mockPrayerLogRepository = {
      create: vi.fn(),
      update: vi.fn(),
      delete: vi.fn(),
      findById: vi.fn(),
      findMany: vi.fn(),
      findManySummarized: vi.fn(),
      findByUserDateAndPrayers: vi.fn(),
      countByUserId: vi.fn(),
      getSummary: vi.fn(),
    };

    createPrayerLogUseCase = new CreatePrayerLogUseCase(mockPrayerLogRepository);
  });

  it("should create a prayer log successfully", async () => {
    const mockData = {
      prayer: "SUBUH",
      date: new Date(),
      performed: true,
      category: "WAJIB",
    };

    const mockResult = { id: "1", ...mockData, user_id: "u1" };
    vi.mocked(mockPrayerLogRepository.findByUserDateAndPrayers).mockResolvedValue([]);
    vi.mocked(mockPrayerLogRepository.create).mockResolvedValue(mockResult as any);

    const result = await createPrayerLogUseCase.execute("u1", mockData as any);

    expect(result).toEqual(mockResult);
    expect(mockPrayerLogRepository.create).toHaveBeenCalled();
  });
});
