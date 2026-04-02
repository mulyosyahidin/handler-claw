import 'package:handlerclaw/core/models/api_response_dto.dart';
import 'package:handlerclaw/features/finances/data/dto/account_type_dto.dart';

class AccountTypesResponseDto extends ApiResponseDto<AccountTypesPaginatedDto> {
  AccountTypesResponseDto({
    required super.success,
    required super.message,
    super.data,
    super.errors,
  });

  factory AccountTypesResponseDto.fromJson(Map<String, dynamic> json) {
    return AccountTypesResponseDto(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] != null ? AccountTypesPaginatedDto.fromJson(json["data"]) : null,
      errors: json["errors"],
    );
  }
}
