import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Future<Map<String, String>> getDeviceInfo() async {
    final androidInfo = await _deviceInfo.androidInfo;

    return {
      "device_id": androidInfo.id,
      "device_brand": androidInfo.brand,
      "device_model": androidInfo.model,
      "os_version": androidInfo.version.release,
    };
  }
}

final deviceServiceProvider = Provider<DeviceService>((ref) {
  return DeviceService();
});

final currentDeviceIdProvider = FutureProvider<String?>((ref) async {
  final info = await ref.read(deviceServiceProvider).getDeviceInfo();
  return info["device_id"];
});
