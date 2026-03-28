import type { Notification, UserDevice } from "../../../../lib/generated/prisma/client.js";

export interface NotificationSender {
  sendToDevice(notification: Notification, userDevice: UserDevice): Promise<string>;
}
