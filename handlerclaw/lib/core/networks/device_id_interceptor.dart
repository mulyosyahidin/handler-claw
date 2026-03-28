import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/services/device_id_service.dart';

class DeviceIdInterceptor extends Interceptor {
  final Ref ref;

  DeviceIdInterceptor(this.ref);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final deviceId = await ref.read(deviceIdServiceProvider).getDeviceId();

    if (deviceId != null) {
      options.headers["x-device-id"] = deviceId;
    }

    handler.next(options);
  }
}
