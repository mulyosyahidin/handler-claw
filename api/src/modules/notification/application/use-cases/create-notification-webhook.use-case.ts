import type { UserDeviceRepository } from "../../../user-device/domain/repositories/user-device.repository.interface.js";
import { SendNotificationUseCase } from "./send-notification.use-case.js";
import type { NotificationWebhookRepository } from "../../domain/repositories/notification-webhook.repository.interface.js";
import type {
  CreateNotificationHookResponse,
  CreateNotificationWebhookData,
} from "../dtos/notification-webhook.dto.js";
import type { NotificationRepository } from "../../domain/repositories/notification.repository.interface.js";
import type { CreateNotificationWebhookRequest } from "../dtos/notification-webhook.dto.js";
import { toNotificationWebhookEntity } from "../../infrastructure/mappers/notification-webhook.mapper.js";
import { toNotificationEntity } from "../../infrastructure/mappers/notification.mapper.js";

export class CreateNotificationWebhookUseCase {
  constructor(
    private notificationWebhookRepository: NotificationWebhookRepository,
    private notificationRepository: NotificationRepository,
    private userDeviceRepository: UserDeviceRepository,
    private sendNotificationUseCase: SendNotificationUseCase,
  ) {}

  async execute(
    userId: string,
    data: CreateNotificationWebhookRequest,
  ): Promise<CreateNotificationHookResponse> {
    const payload: CreateNotificationWebhookData = {
      title: data.title,
      message: data.message,
      ...(data.meta !== undefined && { meta: data.meta }),
    };

    const notificationWebhook = await this.notificationWebhookRepository.create(userId, payload);

    const devices = await this.userDeviceRepository.findAllByActiveStatus(userId);

    const notifications = await Promise.all(
      devices.map(async (device) => {
        const notification = await this.notificationRepository.create({
          notificationWebhookId: notificationWebhook.id,
          userId,
          userDeviceId: device.id,
          title: payload.title,
          body: payload.message,
          status: "PENDING",
          retryCount: 0,
          ...(payload.meta !== undefined && { data: payload.meta }),
        });

        // fire-and-forget
        this.sendNotificationUseCase.execute(userId, notification.id).catch((err: any) => {
          console.error(`[Notification] Failed to trigger send for ${notification.id}:`, err);
        });

        return notification;
      }),
    );

    return {
      notification_webhook: toNotificationWebhookEntity(notificationWebhook),
      notifications: {
        count: notifications.length,
        items: notifications.map(toNotificationEntity),
      },
    };
  }
}
