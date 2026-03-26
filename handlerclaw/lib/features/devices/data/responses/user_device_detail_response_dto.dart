import 'package:handlerclaw/core/models/api_response_dto.dart';
import 'package:handlerclaw/core/models/dto/user_device_dto.dart';

class UserDeviceDetailData {
  final UserDeviceDto userDevice;

  UserDeviceDetailData({required this.userDevice});

  factory UserDeviceDetailData.fromJson(Map<String, dynamic> json) {
    return UserDeviceDetailData(
      userDevice: UserDeviceDto.fromJson(json['user_device']),
    );
  }
}

class UserDeviceDetailResponseDto extends ApiResponseDto<UserDeviceDetailData> {
  UserDeviceDetailResponseDto({
    required super.success,
    required super.message,
    required super.data,
  });

  factory UserDeviceDetailResponseDto.fromJson(Map<String, dynamic> json) {
    return UserDeviceDetailResponseDto(
      success: json['success'] ?? false,
      message: json['message'] ?? "",
      data: json['data'] != null ? UserDeviceDetailData.fromJson(json['data']) : null,
    );
  }
}
