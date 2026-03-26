import 'package:handlerclaw/features/devices/domain/entities/user_device_entity.dart';
import 'package:handlerclaw/features/devices/data/dto/user_device_dto.dart';

class UserDeviceMapper {
  static UserDeviceEntity fromDto(UserDeviceDto dto) {
    return UserDeviceEntity(
      id: dto.id,
      userId: dto.userId,
      deviceId: dto.deviceId,
      deviceBrand: dto.deviceBrand,
      deviceModel: dto.deviceModel,
      osVersion: dto.osVersion,
      fcmToken: dto.fcmToken,
      platform: dto.platform,
      status: dto.status,
      lastSeenAt: dto.lastSeenAt,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }
}
