import { describe, it, expect, vi, beforeEach } from "vitest";
import { UpdateUserDeviceStatusUseCase } from "../update-user-device-status.use-case.js";
import type { UserDeviceRepository } from "../../../domain/repositories/user-device.repository.interface.js";

describe("UpdateUserDeviceStatusUseCase", () => {
  let updateStatusUseCase: UpdateUserDeviceStatusUseCase;
  let mockUserDeviceRepository: UserDeviceRepository;

  beforeEach(() => {
    mockUserDeviceRepository = {
      upsert: vi.fn(),
      updateStatus: vi.fn(),
      findAllActiveByUserId: vi.fn(),
      findById: vi.fn(),
      findMany: vi.fn(),
    };

    updateStatusUseCase = new UpdateUserDeviceStatusUseCase(mockUserDeviceRepository);
  });

  it("should update device status successfully", async () => {
    vi.mocked(mockUserDeviceRepository.updateStatus).mockResolvedValue(undefined as any);

    const result = await updateStatusUseCase.execute("u1", {
      device_id: "d1",
      status: "ACTIVE",
    });

    expect(result).toEqual({ success: true });
    expect(mockUserDeviceRepository.updateStatus).toHaveBeenCalledWith("u1", "d1", "ACTIVE");
  });

  it("should throw error if repository throws", async () => {
    vi.mocked(mockUserDeviceRepository.updateStatus).mockRejectedValue(
      new Error("Device tidak ditemukan"),
    );

    await expect(
      updateStatusUseCase.execute("u1", { device_id: "d1", status: "ACTIVE" }),
    ).rejects.toThrow("Device tidak ditemukan");
  });
});
