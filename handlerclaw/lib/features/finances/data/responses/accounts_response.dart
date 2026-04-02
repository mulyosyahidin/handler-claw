import 'package:handlerclaw/core/models/api_response_dto.dart';
import 'package:handlerclaw/core/models/pagination_meta_dto.dart';
import 'package:handlerclaw/features/finances/data/dto/account_dto.dart';

class AccountsPaginatedDto {
  final List<AccountDto> accounts;
  final PaginationMetaDto meta;

  AccountsPaginatedDto({
    required this.accounts,
    required this.meta,
  });

  factory AccountsPaginatedDto.fromJson(Map<String, dynamic> json) {
    return AccountsPaginatedDto(
      accounts: (json['accounts'] as List?)
              ?.map((e) => AccountDto.fromJson(e))
              .toList() ??
          [],
      meta: PaginationMetaDto.fromJson(json['meta'] ?? {}),
    );
  }
}

class AccountsResponseDto extends ApiResponseDto<AccountsPaginatedDto> {
  AccountsResponseDto({
    required super.success,
    required super.message,
    super.data,
    super.errors,
  });

  factory AccountsResponseDto.fromJson(Map<String, dynamic> json) {
    return AccountsResponseDto(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] != null ? AccountsPaginatedDto.fromJson(json["data"]) : null,
      errors: json["errors"],
    );
  }
}

class AccountResponseDto extends ApiResponseDto<AccountDto> {
  AccountResponseDto({
    required super.success,
    required super.message,
    super.data,
    super.errors,
  });

  factory AccountResponseDto.fromJson(Map<String, dynamic> json) {
    return AccountResponseDto(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] != null && json["data"]["account"] != null
          ? AccountDto.fromJson(json["data"]["account"])
          : null,
      errors: json["errors"],
    );
  }
}
