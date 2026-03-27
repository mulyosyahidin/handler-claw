import type { Notification } from "../entities/notification.entity.js";
import type { UserDevice } from "../../../user-device/domain/entities/user-device.entity.js";

export interface NotificationSender {
  sendToDevice(notification: Notification, userDevice: UserDevice): Promise<string>;
}
