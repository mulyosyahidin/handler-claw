import 'package:handlerclaw/core/models/pagination_meta_dto.dart';
import 'package:handlerclaw/features/api-keys/domain/entities/api_key_entity.dart';

abstract class ApiKeyRepository {
  Future<ApiKeyListResponse> getKeys({
    int page = 1,
    int perPage = 10,
    String? search,
  });

  Future<ApiKeyEntity> createKey(String name);

  Future<ApiKeyEntity> updateKey(String id, String name);

  Future<void> deleteKey(String id);

  Future<ApiKeyEntity> revokeKey(String id);

  Future<ApiKeyEntity> rotateKey(String id);

  Future<ApiKeyEntity> getKeyDetail(String id);
}

class ApiKeyListResponse {
  final List<ApiKeyEntity> keys;
  final PaginationMetaDto meta;

  ApiKeyListResponse({
    required this.keys,
    required this.meta,
  });
}
