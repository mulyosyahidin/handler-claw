import 'package:handlerclaw/core/models/pagination_meta_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/whatsapp-logs/data/datasources/whatsapp_log_remote_data_source.dart';
import 'package:handlerclaw/features/whatsapp-logs/data/mappers/whatsapp_log_mapper.dart';
import 'package:handlerclaw/features/whatsapp-logs/domain/repositories/whatsapp_log_repository.dart';

class WhatsappLogRepositoryImpl implements WhatsappLogRepository {
  final WhatsappLogRemoteDataSource _remoteDataSource;

  WhatsappLogRepositoryImpl(this._remoteDataSource);

  @override
  Future<WhatsappLogListResponse> getLogs({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    final responseDto = await _remoteDataSource.getLogs(
      page: page,
      limit: limit,
      search: search,
    );

    final logs =
        responseDto.data?.whatsappLogs
            .map((dto) => WhatsappLogMapper.fromDto(dto))
            .toList() ??
        [];

    final meta = responseDto.data?.meta;

    return WhatsappLogListResponse(
      logs: logs,
      meta:
          meta ??
          PaginationMetaDto(page: 1, perPage: limit, total: 0, totalPages: 0),
    );
  }
}

final whatsappLogRepositoryProvider = Provider<WhatsappLogRepository>((ref) {
  final remoteDataSource = ref.read(whatsappLogRemoteDataSourceProvider);
  return WhatsappLogRepositoryImpl(remoteDataSource);
});
