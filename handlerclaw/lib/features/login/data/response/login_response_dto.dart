import 'package:handlerclaw/core/model/api_response.dart';
import 'package:handlerclaw/features/login/data/entity/login_data_dto.dart';

class LoginResponseDto extends ApiResponse<LoginDataDto> {
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
      data: json["data"] != null
          ? LoginDataDto.fromJson(json["data"])
          : null,
      errors: json["errors"],
    );
  }
}
