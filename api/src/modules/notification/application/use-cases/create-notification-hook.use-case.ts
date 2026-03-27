import type { NotificationRepository } from "../../domain/repositories/notification.repository.interface.js";
import type { UserDeviceRepository } from "../../../user-device/domain/repositories/user-device.repository.interface.js";
import type {
  CreateNotificationRequest,
  CreateNotificationHookResponse,
} from "../dtos/notification.dto.js";
import { SendNotificationUseCase } from "./send-notification.use-case.js";
import { extractImportantHeaders } from "../../../../utils/common.js";

export class CreateNotificationHookUseCase {
  constructor(
    private notificationRepository: NotificationRepository,
    private userDeviceRepository: UserDeviceRepository,
    private sendNotificationUseCase: SendNotificationUseCase,
  ) {}

  async execute(
    userId: string,
    data: CreateNotificationRequest,
    headers: Record<string, any>,
  ): Promise<CreateNotificationHookResponse> {
    const headersData = extractImportantHeaders(headers);

    const reminderHook = await this.notificationRepository.upsertHook({
      userId,
      eventId: data.event_id,
      payloadJson: data as any,
      headersJson: headersData,
      status: "RECEIVED",
    });

    const devices = await this.userDeviceRepository.findAllActiveByUserId(userId);

    const notifications = await Promise.all(
      devices.map(async (device) => {
        const notification = await this.notificationRepository.createNotification({
          reminderHookId: reminderHook.id,
          userId,
          userDeviceId: device.id,
          title: data.title,
          body: data.message,
          status: "PENDING",
          retryCount: 0,
          data: {
            reminder_hook_id: reminderHook.id,
            event_id: data.event_id,
            type: data.type || "REMINDER",
            link_to: data.link_to || "/",
            created_at: reminderHook.created_at.toISOString(),
          },
        });

        this.sendNotificationUseCase.execute(notification.id).catch((err: any) => {
          console.error(`[Notification] Failed to trigger send for ${notification.id}:`, err);
        });

        return notification;
      }),
    );

    return {
      reminder_hook: reminderHook,
      notifications_count: notifications.length,
    };
  }
}
