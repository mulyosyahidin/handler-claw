import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/app/navigation_keys.dart';
import 'package:handlerclaw/core/notification/pending_notification_provider.dart';
import 'package:handlerclaw/shared/utils/logger.dart';
import 'package:handlerclaw/shared/provider/firebase_messaging_provider.dart';

class FcmHandler {
  final Ref ref;
  final FirebaseMessaging fcm;

  FcmHandler(this.ref, this.fcm);

  Future<void> init() async {
    Logger.info("Initializing FcmHandler...");

    // 1. Permisi Notifikasi (Android 13+)
    await fcm.requestPermission(alert: true, badge: true, sound: true);

    // 2. Handle click saat app di background (bukan terminated)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    // 3. Handle click saat app terminated
    final initialMessage = await fcm.getInitialMessage();
    if (initialMessage != null) {
      Logger.info("App opened from terminated state via notification");
      _handleMessage(initialMessage);
    }

    // 4. Handle foreground message
    FirebaseMessaging.onMessage.listen((message) {
      Logger.info(
        "Foreground message received: ${message.notification?.title}",
      );

      final context = rootNavigatorKey.currentContext;
      if (context != null && context.mounted && message.notification != null) {
        CherryToast.success(
          title: Text(
            message.notification?.title ?? "Notifikasi",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          description: Text(message.notification?.body ?? ""),
          animationType: AnimationType.fromTop,
          toastPosition: Position.top,
          autoDismiss: true,
          action: const Text(
            "LIHAT",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          actionHandler: () {
            _handleMessage(message);
          },
          toastDuration: Duration(seconds: 5),
        ).show(context);
      }
    });

    Logger.info("FcmHandler initialized.");
  }

  void _handleMessage(RemoteMessage message) {
    Logger.info("Notification clicked! Data: ${message.data}");

    final reminderHookId = message.data['reminder_hook_id'];
    if (reminderHookId != null) {
      Logger.info("Registering pending notification: $reminderHookId");
      ref
          .read(pendingNotificationProvider.notifier)
          .setNotification(reminderHookId);
    } else {
      Logger.warning("reminder_hook_id not found in notification data");
    }
  }
}

final fcmHandlerProvider = Provider<FcmHandler>((ref) {
  final fcm = ref.read(firebaseMessagingProvider);
  return FcmHandler(ref, fcm);
});
