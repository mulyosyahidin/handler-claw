import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/whatsapp-hooks/data/datasources/whatsapp_hook_remote_data_source.dart';
import 'package:handlerclaw/features/whatsapp-hooks/data/mappers/whatsapp_message_mapper.dart';
import 'package:handlerclaw/features/whatsapp-hooks/domain/entities/whatsapp_message_entity.dart';
import 'package:handlerclaw/features/whatsapp-hooks/domain/repositories/whatsapp_hook_repository.dart';

class WhatsappHookRepositoryImpl implements WhatsappHookRepository {
  final WhatsappHookRemoteDataSource _remoteDataSource;

  WhatsappHookRepositoryImpl(this._remoteDataSource);

  @override
  Future<({List<WhatsappMessageEntity> messages, int total})> getMessages({
    int page = 1,
    int limit = 10,
    String? search,
    String? chatId,
    WhatsappMessageType? messageType,
    bool? isFromMe,
  }) async {
    final response = await _remoteDataSource.getMessages(
      page: page,
      limit: limit,
      search: search,
      chatId: chatId,
      messageType: messageType,
      isFromMe: isFromMe,
    );

    return (
      messages: response.messages.map(WhatsappMessageMapper.toEntity).toList(),
      total: response.meta.total,
    );
  }
}

final whatsappHookRepositoryProvider = Provider<WhatsappHookRepository>((ref) {
  final remoteDataSource = ref.read(whatsappHookRemoteDataSourceProvider);
  return WhatsappHookRepositoryImpl(remoteDataSource);
});
