import { describe, it, expect, vi, beforeEach } from "vitest";
import { GetUserDevicesUseCase } from "../get-user-devices.use-case.js";
import type { UserDeviceRepository } from "../../../domain/repositories/user-device.repository.interface.js";
import {
  UserDevicePlatform,
  UserDeviceStatus,
} from "../../../../../lib/generated/prisma/client.js";

describe("GetUserDevicesUseCase", () => {
  let getUserDevicesUseCase: GetUserDevicesUseCase;
  let mockUserDeviceRepository: UserDeviceRepository;

  beforeEach(() => {
    mockUserDeviceRepository = {
      upsert: vi.fn(),
      findMany: vi.fn(),
      findById: vi.fn(),
      updateStatus: vi.fn(),
      findAllActiveByUserId: vi.fn(),
    };

    getUserDevicesUseCase = new GetUserDevicesUseCase(mockUserDeviceRepository);
  });

  it("should get user devices successfully", async () => {
    const userId = "user-123";
    const mockQuery = {
      page: 1,
      per_page: 10,
    };

    const mockResults = {
      devices: [
        {
          id: "uuid-1",
          userId,
          deviceId: "dev-1",
          deviceBrand: "Samsung",
          deviceModel: "S21",
          osVersion: "12",
          fcmToken: "token-1",
          platform: UserDevicePlatform.ANDROID,
          status: UserDeviceStatus.ACTIVE,
          lastSeenAt: new Date(),
          createdAt: new Date(),
          updatedAt: new Date(),
        },
      ],
      total: 1,
    };

    vi.mocked(mockUserDeviceRepository.findMany).mockResolvedValue(mockResults as any);

    const result = await getUserDevicesUseCase.execute(userId, mockQuery as any);

    expect(result.user_devices).toHaveLength(1);
    expect(result.meta.total).toBe(1);
    expect(mockUserDeviceRepository.findMany).toHaveBeenCalledWith(userId, mockQuery);
  });
});
