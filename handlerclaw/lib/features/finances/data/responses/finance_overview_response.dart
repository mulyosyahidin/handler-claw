import 'package:handlerclaw/core/models/api_response_dto.dart';
import 'package:handlerclaw/features/finances/data/dto/finance_overview_dto.dart';

class FinanceOverviewResponseDto extends ApiResponseDto<FinanceOverviewDto> {
  FinanceOverviewResponseDto({
    required super.success,
    required super.message,
    super.data,
    super.errors,
  });

  factory FinanceOverviewResponseDto.fromJson(Map<String, dynamic> json) {
    return FinanceOverviewResponseDto(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] != null ? FinanceOverviewDto.fromJson(json["data"]) : null,
      errors: json["errors"],
    );
  }
}
