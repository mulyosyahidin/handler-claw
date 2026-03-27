import { describe, it, expect, vi, beforeEach } from "vitest";
import { CreateNotificationHookUseCase } from "../create-notification-hook.use-case.js";
import type { NotificationRepository } from "../../../domain/repositories/notification.repository.interface.js";
import type { UserDeviceRepository } from "../../../../user-device/domain/repositories/user-device.repository.interface.js";
import type { SendNotificationUseCase } from "../send-notification.use-case.js";

describe("CreateNotificationHookUseCase", () => {
  let createNotificationHookUseCase: CreateNotificationHookUseCase;
  let mockNotificationRepository: NotificationRepository;
  let mockUserDeviceRepository: UserDeviceRepository;
  let mockSendNotificationUseCase: SendNotificationUseCase;

  beforeEach(() => {
    mockNotificationRepository = {
      upsertHook: vi.fn(),
      createNotification: vi.fn(),
      updateNotification: vi.fn(),
      updateHookStatus: vi.fn(),
      findNotificationById: vi.fn(),
      findHookById: vi.fn(),
      findNotificationsSummary: vi.fn(),
      findNotificationsByUserId: vi.fn(),
      findHooksByUserId: vi.fn(),
      getHooksSummary: vi.fn(),
    };

    mockUserDeviceRepository = {
      upsert: vi.fn(),
      updateStatus: vi.fn(),
      findAllActiveByUserId: vi.fn(),
      findById: vi.fn(),
      findMany: vi.fn(),
    };

    mockSendNotificationUseCase = {
      execute: vi.fn(),
    } as any;

    createNotificationHookUseCase = new CreateNotificationHookUseCase(
      mockNotificationRepository,
      mockUserDeviceRepository,
      mockSendNotificationUseCase,
    );
  });

  it("should create hook and notifications successfully", async () => {
    const mockData = {
      event_id: "e1",
      title: "Test",
      message: "Test Message",
      type: "REMINDER",
      link_to: "/",
    };

    const mockHook = { id: "h1", created_at: new Date(), ...mockData };
    const mockDevices = [{ id: "d1", fcm_token: "t1" }];

    vi.mocked(mockNotificationRepository.upsertHook).mockResolvedValue(mockHook as any);
    vi.mocked(mockUserDeviceRepository.findAllActiveByUserId).mockResolvedValue(mockDevices as any);
    vi.mocked(mockNotificationRepository.createNotification).mockResolvedValue({ id: "n1" } as any);

    await createNotificationHookUseCase.execute("u1", mockData as any, {});

    expect(mockNotificationRepository.upsertHook).toHaveBeenCalled();
    expect(mockNotificationRepository.createNotification).toHaveBeenCalled();
  });
});
