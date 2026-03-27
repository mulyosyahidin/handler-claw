import { describe, it, expect, vi, beforeEach } from "vitest";
import { SendNotificationUseCase } from "../send-notification.use-case.js";
import type { NotificationRepository } from "../../../domain/repositories/notification.repository.interface.js";
import type { UserDeviceRepository } from "../../../../user-device/domain/repositories/user-device.repository.interface.js";
import type { NotificationSender } from "../../../domain/services/notification-sender.service.interface.js";

describe("SendNotificationUseCase", () => {
  let sendNotificationUseCase: SendNotificationUseCase;
  let mockNotificationRepository: NotificationRepository;
  let mockUserDeviceRepository: UserDeviceRepository;
  let mockNotificationSender: NotificationSender;

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

    mockNotificationSender = {
      sendToDevice: vi.fn(),
    };

    sendNotificationUseCase = new SendNotificationUseCase(
      mockNotificationRepository,
      mockUserDeviceRepository,
      mockNotificationSender,
    );
  });

  it("should send notification successfully", async () => {
    const mockNotification = {
      id: "n1",
      user_id: "u1",
      user_device_id: "d1",
      reminder_hook_id: "h1",
      title: "Test",
      body: "Test Body",
    };
    const mockDevice = { id: "d1", fcm_token: "token1" };

    vi.mocked(mockNotificationRepository.findNotificationById).mockResolvedValue(
      mockNotification as any,
    );
    vi.mocked(mockUserDeviceRepository.findById).mockResolvedValue(mockDevice as any);
    vi.mocked(mockNotificationSender.sendToDevice).mockResolvedValue("msg123");

    const result = await sendNotificationUseCase.execute("n1");

    expect(result.success).toBe(true);
    expect(mockNotificationSender.sendToDevice).toHaveBeenCalled();
    expect(mockNotificationRepository.updateNotification).toHaveBeenCalled();
  });
});
