import 'package:handlerclaw/core/models/api_response_dto.dart';

class PasswordUpdateResponseDto extends ApiResponseDto<void> {
  PasswordUpdateResponseDto({
    required super.success,
    required super.message,
  });

  factory PasswordUpdateResponseDto.fromJson(Map<String, dynamic> json) {
    return PasswordUpdateResponseDto(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
    );
  }
}
