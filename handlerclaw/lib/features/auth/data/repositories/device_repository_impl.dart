import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/networks/dio_client.dart';
import 'package:handlerclaw/core/providers/firebase_messaging_provider.dart';
import 'package:handlerclaw/features/auth/domain/repositories/device_repository.dart';
import 'package:handlerclaw/core/services/device_id_service.dart';
import 'package:handlerclaw/core/services/device_info_plus_service.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final Dio dio;
  final FirebaseMessaging firebaseMessaging;
  final DeviceInfoPlusService deviceService;
  final DeviceIdService deviceIdService;

  DeviceRepositoryImpl(
    this.dio,
    this.firebaseMessaging,
    this.deviceService,
    this.deviceIdService,
  );

  @override
  Future<void> registerDevice() async {
    final fcmToken = await firebaseMessaging.getToken();

    if (fcmToken == null) return;

    final deviceInfo = await deviceService.getDeviceInfo();
    final androidId = await deviceIdService.getDeviceId();

    await dio.post(
      "/user-devices",
      data: {
        "device_id": androidId,
        "fcm_token": fcmToken,
        "platform": "ANDROID",
        "device_brand": deviceInfo["device_brand"],
        "device_model": deviceInfo["device_model"],
        "os_version": deviceInfo["os_version"],
      },
    );
  }

  @override
  Future<void> markAsLogout() async {
    final androidId = await deviceIdService.getDeviceId();

    await dio.patch(
      "/user-devices/status",
      data: {"device_id": androidId, "status": "LOGGED_OUT"},
    );
  }
}

final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  final dio = ref.read(dioProvider);
  final messaging = ref.read(firebaseMessagingProvider);
  final deviceService = ref.read(deviceInfoPlusServiceProvider);
  final deviceIdService = ref.read(deviceIdServiceProvider);

  return DeviceRepositoryImpl(dio, messaging, deviceService, deviceIdService);
});
