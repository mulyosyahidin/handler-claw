import { describe, it, expect, vi, beforeEach } from "vitest";
import { GetUserDeviceDetailUseCase } from "../get-user-device-detail.use-case.js";
import type { UserDeviceRepository } from "../../../domain/repositories/user-device.repository.interface.js";

describe("GetUserDeviceDetailUseCase", () => {
  let getUserDeviceDetailUseCase: GetUserDeviceDetailUseCase;
  let mockUserDeviceRepository: UserDeviceRepository;

  beforeEach(() => {
    mockUserDeviceRepository = {
      upsert: vi.fn(),
      updateStatus: vi.fn(),
      findAllActiveByUserId: vi.fn(),
      findById: vi.fn(),
      findMany: vi.fn(),
    };

    getUserDeviceDetailUseCase = new GetUserDeviceDetailUseCase(mockUserDeviceRepository);
  });

  it("should get device detail successfully", async () => {
    const mockDevice = { id: "d1", userId: "u1", deviceId: "device1" };
    vi.mocked(mockUserDeviceRepository.findById).mockResolvedValue(mockDevice as any);

    const result = await getUserDeviceDetailUseCase.execute("u1", { id: "d1" });

    expect(result.user_device).toEqual(mockDevice);
    expect(mockUserDeviceRepository.findById).toHaveBeenCalledWith("u1", "d1");
  });

  it("should throw error if device not found", async () => {
    vi.mocked(mockUserDeviceRepository.findById).mockResolvedValue(null);

    await expect(getUserDeviceDetailUseCase.execute("u1", { id: "d1" })).rejects.toThrow(
      "Device not found",
    );
  });
});
