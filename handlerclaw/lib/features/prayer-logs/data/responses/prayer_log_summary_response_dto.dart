import 'package:handlerclaw/core/models/api_response_dto.dart';
import 'package:handlerclaw/features/prayer-logs/data/dto/count_dto.dart';
import 'package:handlerclaw/features/prayer-logs/data/dto/filter_dto.dart';
import 'package:handlerclaw/features/prayer-logs/data/dto/grand_total_dto.dart';
import 'package:handlerclaw/features/prayer-logs/data/dto/performance_dto.dart';
import 'package:handlerclaw/features/prayer-logs/data/dto/summary_item_dto.dart';

class PrayerLogSummaryData {
  final List<SummaryItemDto> summary;
  final CountDto count;
  final PerformancesDto performances;
  final GrandTotalDto grandTotal;
  final FilterDto filter;

  PrayerLogSummaryData({
    required this.summary,
    required this.count,
    required this.performances,
    required this.grandTotal,
    required this.filter,
  });

  factory PrayerLogSummaryData.fromJson(Map<String, dynamic> json) {
    return PrayerLogSummaryData(
      summary: (json["summary"] as List<dynamic>?)
          ?.map((e) => SummaryItemDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      count: CountDto.fromJson(json["count"] ?? {}),
      performances: PerformancesDto.fromJson(json["performances"] ?? {}),
      grandTotal: GrandTotalDto.fromJson(json["grand_total"] ?? {}),
      filter: FilterDto.fromJson(json["filter"] ?? {}),
    );
  }
}

class PrayerLogSummaryResponseDto extends ApiResponseDto<PrayerLogSummaryData> {
  PrayerLogSummaryResponseDto({
    required super.success,
    required super.message,
    required super.data,
    super.errors,
  });

  factory PrayerLogSummaryResponseDto.fromJson(Map<String, dynamic> json) {
    return PrayerLogSummaryResponseDto(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] != null
          ? PrayerLogSummaryData.fromJson(json["data"])
          : null,
      errors: json["errors"],
    );
  }
}