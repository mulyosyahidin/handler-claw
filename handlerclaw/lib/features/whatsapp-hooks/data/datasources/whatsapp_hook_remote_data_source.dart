import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/config/api_endpoint.dart';
import 'package:handlerclaw/core/networks/dio_client.dart';
import 'package:handlerclaw/core/utils/logger.dart';
import 'package:handlerclaw/features/whatsapp-hooks/data/responses/whatsapp_message_list_response_dto.dart';
import 'package:handlerclaw/features/whatsapp-hooks/domain/entities/whatsapp_message_entity.dart';

class WhatsappHookRemoteDataSource {
  final Dio _dio;

  WhatsappHookRemoteDataSource(this._dio);

  Future<WhatsappMessageListResponseDto> getMessages({
    int page = 1,
    int limit = 10,
    String? search,
    String? chatId,
    WhatsappMessageType? messageType,
    bool? isFromMe,
  }) async {
    const endpoint = ApiEndpoint.whatsappMessageList;

    try {
      Logger.api("GET", endpoint);

      final response = await _dio.get(
        endpoint,
        queryParameters: {
          "page": page,
          "per_page": limit,
          if (search != null && search.isNotEmpty) "search": search,
          if (chatId != null && chatId.isNotEmpty) "chat_id": chatId,
          if (messageType != null)
            "message_type": messageType.name.toUpperCase(),
          "is_from_me": ?isFromMe,
        },
      );

      return WhatsappMessageListResponseDto.fromJson(response.data);
    } on DioException catch (e, stackTrace) {
      Logger.error("Api Error on endpoint $endpoint: ${e.message}");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'WhatsappHookRemoteDataSource.getMessages (DioException)',
      );
      rethrow;
    } catch (e, stackTrace) {
      Logger.error("Unexpected error on endpoint $endpoint: $e");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'WhatsappHookRemoteDataSource.getMessages (Unexpected)',
      );
      rethrow;
    }
  }
}

final whatsappHookRemoteDataSourceProvider =
    Provider<WhatsappHookRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);
  return WhatsappHookRemoteDataSource(dio);
});
