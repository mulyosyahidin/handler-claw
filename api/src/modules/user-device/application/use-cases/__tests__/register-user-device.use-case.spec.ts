import { describe, it, expect, vi, beforeEach } from "vitest";
import { RegisterUserDeviceUseCase } from "../register-user-device.use-case.js";
import type { UserDeviceRepository } from "../../../domain/repositories/user-device.repository.interface.js";
import {
  UserDevicePlatform,
  UserDeviceStatus,
} from "../../../../../lib/generated/prisma/client.js";

describe("RegisterUserDeviceUseCase", () => {
  let registerUserDeviceUseCase: RegisterUserDeviceUseCase;
  let mockUserDeviceRepository: UserDeviceRepository;

  beforeEach(() => {
    mockUserDeviceRepository = {
      upsert: vi.fn(),
      findMany: vi.fn(),
      findById: vi.fn(),
      updateStatus: vi.fn(),
      findAllActiveByUserId: vi.fn(),
    };

    registerUserDeviceUseCase = new RegisterUserDeviceUseCase(mockUserDeviceRepository);
  });

  it("should register user device successfully", async () => {
    const userId = "user-123";
    const mockInput = {
      device_id: "dev-1",
      device_brand: "Samsung",
      device_model: "S21",
      os_version: "12",
      fcm_token: "token-123",
      platform: UserDevicePlatform.ANDROID,
    };

    const mockResult = {
      id: "uuid-1",
      userId,
      deviceId: "dev-1",
      deviceBrand: "Samsung",
      deviceModel: "S21",
      osVersion: "12",
      fcmToken: "token-123",
      platform: UserDevicePlatform.ANDROID,
      status: UserDeviceStatus.ACTIVE,
      lastSeenAt: new Date(),
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    vi.mocked(mockUserDeviceRepository.upsert).mockResolvedValue(mockResult as any);

    const result = await registerUserDeviceUseCase.execute(userId, mockInput as any);

    expect(result.user_device.id).toBe("uuid-1");
    expect(mockUserDeviceRepository.upsert).toHaveBeenCalledWith(userId, mockInput);
  });
});
