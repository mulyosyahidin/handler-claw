import 'package:handlerclaw/core/models/api_response_dto.dart';
import 'package:handlerclaw/core/models/pagination_meta_dto.dart';
import 'package:handlerclaw/features/api-keys/data/dto/api_key_dto.dart';

class ApiKeyListData {
  final List<ApiKeyDto> apiKeys;
  final PaginationMetaDto meta;

  ApiKeyListData({
    required this.apiKeys,
    required this.meta,
  });

  factory ApiKeyListData.fromJson(Map<String, dynamic> json) {
    return ApiKeyListData(
      apiKeys: (json['api_keys'] as List<dynamic>?)
              ?.map((e) => ApiKeyDto.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
      meta: PaginationMetaDto.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}

class ApiKeyListResponseDto extends ApiResponseDto<ApiKeyListData> {
  ApiKeyListResponseDto({
    required super.success,
    required super.message,
    required super.data,
    super.errors,
  });

  factory ApiKeyListResponseDto.fromJson(Map<String, dynamic> json) {
    return ApiKeyListResponseDto(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] != null
          ? ApiKeyListData.fromJson(json["data"])
          : null,
      errors: json["errors"],
    );
  }
}
