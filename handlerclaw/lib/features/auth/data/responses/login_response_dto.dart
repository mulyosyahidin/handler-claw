import 'package:handlerclaw/core/models/api_response_dto.dart';
import 'package:handlerclaw/features/auth/data/dto/user_dto.dart';

class LoginData {
  final UserDto user;
  final String accessToken;

  LoginData({required this.user, required this.accessToken});

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      user: UserDto.fromJson(json["user"]),
      accessToken: json["access_token"],
    );
  }
}

class LoginResponseDto extends ApiResponseDto<LoginData> {
  LoginResponseDto({
    required super.success,
    required super.message,
    required super.data,
    super.errors,
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] != null ? LoginData.fromJson(json["data"]) : null,
      errors: json["errors"],
    );
  }
}
