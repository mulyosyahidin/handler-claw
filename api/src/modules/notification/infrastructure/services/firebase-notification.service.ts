import { getFirebaseAdmin } from "../../../../lib/firebase-admin.js";
import type { NotificationSender } from "../../domain/services/notification-sender.service.interface.js";
import { toFcmData } from "../../../../utils/common.js";
import type { Notification, UserDevice } from "../../../../lib/generated/prisma/client.js";

export class FirebaseNotificationService implements NotificationSender {
  async sendToDevice(notification: Notification, userDevice: UserDevice): Promise<string> {
    const message = {
      token: userDevice.fcmToken,
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
