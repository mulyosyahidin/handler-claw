import 'package:handlerclaw/core/model/api_response_dto.dart';
import 'package:handlerclaw/features/auth/data/dto/user_dto.dart';

class MeData {
  final UserDto user;

  MeData({required this.user});

  factory MeData.fromJson(Map<String, dynamic> json) {
    return MeData(user: UserDto.fromJson(json["user"]));
  }
}

class MeResponseDto extends ApiResponseDto<MeData> {
  MeResponseDto({
    required super.success,
    required super.message,
    required super.data,
    super.errors,
  });

  factory MeResponseDto.fromJson(Map<String, dynamic> json) {
    return MeResponseDto(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] != null ? MeData.fromJson(json["data"]) : null,
      errors: json["errors"],
    );
  }
}
