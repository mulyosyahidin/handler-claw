import 'package:handlerclaw/core/models/api_response_dto.dart';
import 'package:handlerclaw/core/models/pagination_meta_dto.dart';
import 'package:handlerclaw/features/prayer-logs/data/dto/prayer_log_dto.dart';

class PrayerLogListData {
  final List<PrayerLogDto> prayerLogs;
  final PaginationMetaDto meta;
  final dynamic filter;

  PrayerLogListData({
    required this.prayerLogs,
    required this.meta,
    this.filter,
  });

  factory PrayerLogListData.fromJson(Map<String, dynamic> json) {
    return PrayerLogListData(
      prayerLogs:
          (json['prayer_logs'] as List<dynamic>?)
              ?.map((e) => PrayerLogDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      meta: PaginationMetaDto.fromJson(json['meta'] ?? {}),
      filter: json['filter'],
    );
  }
}

class PrayerLogListResponseDto extends ApiResponseDto<PrayerLogListData> {
  PrayerLogListResponseDto({
    required super.success,
    required super.message,
    required super.data,
    super.errors,
  });

  factory PrayerLogListResponseDto.fromJson(Map<String, dynamic> json) {
    return PrayerLogListResponseDto(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] != null
          ? PrayerLogListData.fromJson(json["data"])
          : null,
      errors: json["errors"],
    );
  }
}
