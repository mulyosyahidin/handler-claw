import { getFirebaseAdmin } from "../../../../lib/firebase-admin.js";
import type { Notification } from "../../domain/entities/notification.entity.js";
import type { UserDevice } from "../../../user-device/domain/entities/user-device.entity.js";
import type { NotificationSender } from "../../domain/services/notification-sender.service.interface.js";
import { toFcmData } from "../../../../utils/common.js";

export class FirebaseNotificationService implements NotificationSender {
  async sendToDevice(notification: Notification, userDevice: UserDevice): Promise<string> {
    const message = {
      token: userDevice.fcm_token,
      notification: {
        title: notification.title,
        body: notification.body,
      },
      data: toFcmData(notification.data as any),
      android: {
        priority: "high" as const,
        notification: {
          channelId: "default_channel",
          priority: "high" as const,
          defaultSound: true,
          defaultVibrateTimings: true,
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    };

    const firebaseAdmin = getFirebaseAdmin();
    return await firebaseAdmin.messaging().send(message);
  }
}
