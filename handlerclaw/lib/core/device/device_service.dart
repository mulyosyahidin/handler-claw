import 'package:device_info_plus/device_info_plus.dart';

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