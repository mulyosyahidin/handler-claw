import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/whatsapp-logs/data/datasources/whatsapp_log_remote_data_source.dart';
import 'package:handlerclaw/features/whatsapp-logs/data/mappers/whatsapp_log_mapper.dart';
import 'package:handlerclaw/features/whatsapp-logs/domain/repositories/whatsapp_log_repository.dart';

class WhatsappLogRepositoryImpl implements WhatsappLogRepository {
  final WhatsappLogRemoteDataSource _remoteDataSource;

  WhatsappLogRepositoryImpl(this._remoteDataSource);

  @override
  Future<WhatsappLogListResponse> getLogs({
    int? cursor,
    int limit = 10,
    String? search,
  }) async {
    final responseDto = await _remoteDataSource.getLogs(
      cursor: cursor,
      limit: limit,
      search: search,
    );

    final logs =
        responseDto.data?.whatsappLogs
            .map((dto) => WhatsappLogMapper.fromDto(dto))
            .toList() ??
        [];

    return WhatsappLogListResponse(
      logs: logs,
      nextCursor: responseDto.data?.nextCursor,
    );
  }
}

final whatsappLogRepositoryProvider = Provider<WhatsappLogRepository>((ref) {
  final remoteDataSource = ref.read(whatsappLogRemoteDataSourceProvider);
  return WhatsappLogRepositoryImpl(remoteDataSource);
});
