import 'package:handlerclaw/features/prayer-logs/domain/entities/prayer_log_summary_entity.dart';
import 'package:handlerclaw/features/prayer-logs/data/responses/prayer_log_list_response_dto.dart';

abstract class PrayerLogRepository {
  Future<PrayerLogListResponseDto> getLogs({
    int page = 1,
    int perPage = 10,
    String? dateType,
    String? start,
    String? end,
  });

  Future<SummaryItemEntity?> getTodaySummary();

  Future<PrayerLogSummaryEntity> getSummary({
    String? dateType,
    String? start,
    String? end,
  });

  Future<void> create({
    required String prayer,
    required DateTime performedAt,
    required String method,
    required String place,
  });
}
