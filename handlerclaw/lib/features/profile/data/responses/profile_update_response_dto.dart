import 'package:handlerclaw/core/models/api_response_dto.dart';
import 'package:handlerclaw/core/data/dto/user_dto.dart';

class ProfileUpdateData {
  final UserDto user;

  ProfileUpdateData({required this.user});

  factory ProfileUpdateData.fromJson(Map<String, dynamic> json) {
    return ProfileUpdateData(
      user: UserDto.fromJson(json['user'] ?? {}),
    );
  }
}

class ProfileUpdateResponseDto extends ApiResponseDto<ProfileUpdateData> {
  ProfileUpdateResponseDto({
    required super.success,
    required super.message,
    required super.data,
    super.errors,
  });

  factory ProfileUpdateResponseDto.fromJson(Map<String, dynamic> json) {
    return ProfileUpdateResponseDto(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] != null
          ? ProfileUpdateData.fromJson(json["data"])
          : null,
      errors: json["errors"],
    );
  }
}
