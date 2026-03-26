import 'package:handlerclaw/core/models/api_response_dto.dart';
import 'package:handlerclaw/features/devices/data/dto/user_device_dto.dart';
import 'package:handlerclaw/core/models/pagination_meta_dto.dart';

class UserDeviceListData {
  final List<UserDeviceDto> userDevices;
  final PaginationMetaDto meta;

  UserDeviceListData({required this.userDevices, required this.meta});

  factory UserDeviceListData.fromJson(Map<String, dynamic> json) {
    return UserDeviceListData(
      userDevices:
          (json['user_devices'] as List<dynamic>?)
              ?.map((e) => UserDeviceDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      meta: PaginationMetaDto.fromJson(json['meta'] ?? {}),
    );
  }
}

class UserDeviceListResponseDto extends ApiResponseDto<UserDeviceListData> {
  UserDeviceListResponseDto({
    required super.success,
    required super.message,
    required super.data,
    super.errors,
  });

  factory UserDeviceListResponseDto.fromJson(Map<String, dynamic> json) {
    return UserDeviceListResponseDto(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] != null
          ? UserDeviceListData.fromJson(json["data"])
          : null,
      errors: json["errors"],
    );
  }
}
