import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/prayer-logs/data/datasources/prayer_log_remote_data_source.dart';
import 'package:handlerclaw/features/prayer-logs/data/mappers/prayer_log_mapper.dart';
import 'package:handlerclaw/features/prayer-logs/data/responses/prayer_log_list_response_dto.dart';
import 'package:handlerclaw/features/prayer-logs/data/dto/prayer_log_create_request_dto.dart';
import 'package:handlerclaw/features/prayer-logs/domain/entities/prayer_log_summary_entity.dart';
import 'package:handlerclaw/features/prayer-logs/domain/repositories/prayer_log_repository.dart';
import 'package:intl/intl.dart';

class PrayerLogRepositoryImpl implements PrayerLogRepository {
  final PrayerLogRemoteDataSource _remoteDataSource;

  PrayerLogRepositoryImpl(this._remoteDataSource);

  @override
  Future<PrayerLogListResponseDto> getLogs({
    int page = 1,
    int perPage = 10,
    String? dateType,
    String? start,
    String? end,
  }) async {
    return await _remoteDataSource.getLogs(
      page: page,
      perPage: perPage,
      dateType: dateType,
      start: start,
      end: end,
    );
  }

  @override
  Future<SummaryItemEntity?> getTodaySummary() async {
    final entity = await getSummary(dateType: 'today');
    return entity.summaryList.isNotEmpty ? entity.summaryList.first : null;
  }

  @override
  Future<PrayerLogSummaryEntity> getSummary({
    String? dateType,
    String? start,
    String? end,
  }) async {
    final response = await _remoteDataSource.getSummary(
      dateType: dateType,
      start: start,
      end: end,
    );
    
    if (response.data == null) {
      throw Exception(response.message);
    }

    return PrayerLogMapper.fromSummaryDto(response.data!);
  }

  @override
  Future<void> create({
    required String prayer,
    required DateTime performedAt,
    required String method,
    required String place,
  }) async {
    // 1. Format timezone offset (e.g., +07:00)
    final offset = performedAt.timeZoneOffset;
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    final sign = offset.isNegative ? '-' : '+';
    final timezone = '$sign$hours:$minutes';

    // 2. Format ISO8601 string without the Z but with offset
    final performedAtStr =
        '${DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(performedAt)}$timezone';
    
    // 3. Format local date
    final localDate = DateFormat('yyyy-MM-dd').format(performedAt);

    await _remoteDataSource.create(
      PrayerLogCreateRequestDto(
        prayer: prayer,
        performedAt: performedAtStr,
        localDate: localDate,
        method: method,
        place: place,
      ),
    );
  }
}

final prayerLogRepositoryProvider = Provider<PrayerLogRepository>((ref) {
  final remoteDataSource = ref.read(prayerLogRemoteDataSourceProvider);
  return PrayerLogRepositoryImpl(remoteDataSource);
});
