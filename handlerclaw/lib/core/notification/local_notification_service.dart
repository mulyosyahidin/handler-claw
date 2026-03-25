import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/provider/fcm_message_handler_provider.dart';
import 'package:handlerclaw/core/utils/logger.dart';

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Ref? _ref;

  bool _initialized = false;

  /// Set reference untuk mengakses provider
  void setRef(Ref ref) {
    _ref = ref;
  }

  /// Inisialisasi plugin notifikasi
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@drawable/ic_notification',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Buat notification channel untuk Android
    await _createNotificationChannel();

    _initialized = true;
  }

  /// Buat notification channel (Android 8.0+)
  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'default_channel',
      'Notifikasi Default',
      description: 'Channel untuk notifikasi reminder',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(channel);
  }

  /// Tampilkan notifikasi
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    final androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Notifikasi Default',
      channelDescription: 'Channel untuk notifikasi reminder',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@drawable/ic_notification',
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Convert payload ke JSON string
    final payloadString = payload != null ? jsonEncode(payload) : null;

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payloadString,
    );
  }

  /// Handler ketika notifikasi di-tap
  void _onNotificationTap(NotificationResponse response) {
    Logger.debug('[LocalNotification] Notifikasi di-tap: ${response.payload}');

    final payloadString = response.payload;

    if (payloadString == null || _ref == null) return;

    try {
      final payload = jsonDecode(payloadString) as Map<String, dynamic>;
      final handler = _ref!.read(fcmMessageHandlerProvider);
      handler.handleLocalNotificationTap(payload);
    } catch (e) {
      Logger.error('[LocalNotification] Error parsing payload: $e');
    }
  }

  /// Cancel semua notifikasi
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Cancel notifikasi berdasarkan id
  Future<void> cancel(int id) async {
    await _plugin.cancel(id: id);
  }
}