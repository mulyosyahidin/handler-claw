import 'package:handlerclaw/features/whatsapp-logs/domain/entities/whatsapp_log_entity.dart';

abstract class WhatsappLogRepository {
  Future<WhatsappLogListResponse> getLogs({
    int? cursor,
    int limit = 10,
    String? search,
  });
}

class WhatsappLogListResponse {
  final List<WhatsappLogEntity> logs;
  final int? nextCursor;

  WhatsappLogListResponse({
    required this.logs,
    this.nextCursor,
  });
}
