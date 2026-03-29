import 'package:handlerclaw/core/models/pagination_meta_dto.dart';
import 'package:handlerclaw/features/whatsapp-logs/domain/entities/whatsapp_log_entity.dart';

abstract class WhatsappLogRepository {
  Future<WhatsappLogListResponse> getLogs({
    int page = 1,
    int limit = 10,
    String? search,
    bool? isGroup,
  });
}

class WhatsappLogListResponse {
  final List<WhatsappLogEntity> logs;
  final PaginationMetaDto meta;

  WhatsappLogListResponse({
    required this.logs,
    required this.meta,
  });
}
