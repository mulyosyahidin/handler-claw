import 'package:handlerclaw/features/devices/domain/entities/user_device_entity.dart';

abstract class UserDeviceRepository {
  Future<UserDeviceListResult> getDevices({
    int page = 1,
    int perPage = 10,
    String? search,
  });

  Future<UserDeviceEntity?> getDeviceDetail(String id);
}

class UserDeviceListResult {
  final List<UserDeviceEntity> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;

  UserDeviceListResult({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });
}
