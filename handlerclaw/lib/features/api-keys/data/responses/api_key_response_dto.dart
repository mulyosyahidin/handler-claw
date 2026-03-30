import 'package:handlerclaw/core/models/api_response_dto.dart';
import 'package:handlerclaw/features/api-keys/data/dto/api_key_dto.dart';

class ApiKeyData {
  final ApiKeyDto apiKey;

  ApiKeyData({required this.apiKey});

  factory ApiKeyData.fromJson(Map<String, dynamic> json) {
    return ApiKeyData(
      apiKey: ApiKeyDto.fromJson(json['api_key']),
    );
  }
}

class ApiKeyResponseDto extends ApiResponseDto<ApiKeyData> {
  ApiKeyResponseDto({
    required super.success,
    required super.message,
    required super.data,
    super.errors,
  });

  factory ApiKeyResponseDto.fromJson(Map<String, dynamic> json) {
    return ApiKeyResponseDto(
      success: json['success'] ?? false,
      message: json['message'] ?? "",
      data: json['data'] != null ? ApiKeyData.fromJson(json['data']) : null,
      errors: json['errors'],
    );
  }
}
