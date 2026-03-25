import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:handlerclaw/app/navigation_keys.dart';
import 'package:handlerclaw/app/routes.dart';
import 'package:handlerclaw/core/data/dto/notification_dto.dart';
import 'package:handlerclaw/core/provider/local_notification_service_provider.dart';
import 'package:handlerclaw/core/utils/logger.dart';

class FcmMessageHandler {
  final Ref _ref;

  FcmMessageHandler(this._ref);

  void initialize() {
    _setupForegroundMessageHandler();
    _setupMessageOpenedApp();
    _checkInitialMessage();
  }

  /// Check jika app dibuka dari terminated state via notifikasi
  void _checkInitialMessage() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      Logger.debug('[FCM] App dibuka dari terminated state via notifikasi');
      _navigateToNotificationDetail(initialMessage);
    }
  }

  /// Setup handler untuk pesan foreground
  void _setupForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleForegroundMessage(message);
    });
  }

  /// Setup handler untuk app yang dibuka dari notifikasi
  void _setupMessageOpenedApp() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessageOpenedApp(message);
    });
  }

  /// Handle pesan ketika app di foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    Logger.debug('[FCM] Pesan foreground diterima:');
    Logger.debug('  Title: ${message.notification?.title}');
    Logger.debug('  Body: ${message.notification?.body}');
    Logger.debug('  Data: ${message.data}');

    // Tampilkan notifikasi lokal
    final notificationService = _ref.read(localNotificationServiceProvider);
    await notificationService.initialize();

    // Buat payload dengan title dan body
    final payload = {
      ...message.data,
      'title': message.notification?.title ?? '',
      'body': message.notification?.body ?? '',
    };

    await notificationService.showNotification(
      id: _generateNotificationId(),
      title: message.notification?.title ?? 'Notifikasi Baru',
      body: message.notification?.body ?? '',
      payload: payload,
    );
  }

  /// Handle ketika app dibuka dari notifikasi
  void _handleMessageOpenedApp(RemoteMessage message) {
    Logger.debug('[FCM] App dibuka dari notifikasi:');
    Logger.debug('  Data: ${message.data}');
    _navigateToNotificationDetail(message);
  }

  /// Navigasi ke halaman detail notifikasi
  void _navigateToNotificationDetail(RemoteMessage message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = rootNavigatorKey.currentContext;

      if (context == null) {
        debugPrint('[FCM] Navigator context masih null');
        return;
      }

      final data = NotificationDto(
        title: message.notification?.title ?? message.data['title'],
        body: message.notification?.body ?? message.data['body'],
        eventId: message.data['event_id'],
        type: message.data['type'],
        linkTo: message.data['link_to'],
        triggeredAt: message.data['triggered_at'],
        rawData: message.data,
      );

      context.push(Routes.notificationDetail, extra: data);
    });
  }

  /// Handle ketika notifikasi lokal di-tap
  void handleLocalNotificationTap(Map<String, dynamic> payload) {
    Logger.debug('[FCM] Notifikasi lokal di-tap: $payload');

    final navigator = rootNavigatorKey.currentState;

    if (navigator == null) {
      Logger.debug('[FCM] Navigator belum siap');
      return;
    }

    debugPrint('[FCM] Membuka halaman detail notifikasi');

    final data = NotificationDto.fromMap(payload);
    navigator.context.push(
      Routes.notificationDetail,
      extra: data,
    );
  }

  /// Generate unique notification ID
  int _generateNotificationId() {
    return Random().nextInt(100000);
  }
}
