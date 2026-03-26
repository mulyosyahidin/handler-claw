import 'package:handlerclaw/core/models/api_response_dto.dart';
import 'package:handlerclaw/features/home/data/dto/overview_count_dto.dart';

class OverviewData {
  final OverviewCountDto count;

  OverviewData({required this.count});

  factory OverviewData.fromJson(Map<String, dynamic> json) {
    return OverviewData(
      count: OverviewCountDto.fromJson(json['count'] ?? {}),
    );
  }
}

class OverviewResponseDto extends ApiResponseDto<OverviewData> {
  OverviewResponseDto({
    required super.success,
    required super.message,
    super.data,
    super.errors,
  });

  factory OverviewResponseDto.fromJson(Map<String, dynamic> json) {
    return OverviewResponseDto(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] != null ? OverviewData.fromJson(json["data"]) : null,
      errors: json["errors"],
    );
  }
}
