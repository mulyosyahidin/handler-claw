import 'package:android_id/android_id.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceIdService {
  final _androidId = const AndroidId();

  Future<String?> getDeviceId() async {
    return await _androidId.getId();
  }
}

final deviceIdServiceProvider = Provider<DeviceIdService>((ref) {
  return DeviceIdService();
});

final currentAndroidIdProvider = FutureProvider<String?>((ref) async {
  return await ref.read(deviceIdServiceProvider).getDeviceId();
});
