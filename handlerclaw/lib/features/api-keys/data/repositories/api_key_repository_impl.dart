import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/models/pagination_meta_dto.dart';
import 'package:handlerclaw/features/api-keys/data/datasources/api_key_remote_data_source.dart';
import 'package:handlerclaw/features/api-keys/data/mappers/api_key_mapper.dart';
import 'package:handlerclaw/features/api-keys/domain/entities/api_key_entity.dart';
import 'package:handlerclaw/features/api-keys/domain/repositories/api_key_repository.dart';

class ApiKeyRepositoryImpl implements ApiKeyRepository {
  final ApiKeyRemoteDataSource _remoteDataSource;

  ApiKeyRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiKeyListResponse> getKeys({
    int page = 1,
    int perPage = 10,
    String? search,
  }) async {
    final responseDto = await _remoteDataSource.getKeys(
      page: page,
      perPage: perPage,
      search: search,
    );

    final keys =
        responseDto.data?.apiKeys
            .map((dto) => ApiKeyMapper.toEntity(dto))
            .toList() ??
        [];

    final meta =
        responseDto.data?.meta ??
        PaginationMetaDto(page: 1, perPage: perPage, total: 0, totalPages: 0);

    return ApiKeyListResponse(keys: keys, meta: meta);
  }

  @override
  Future<ApiKeyEntity> createKey(String name) async {
    final responseDto = await _remoteDataSource.createKey(name);
    return ApiKeyMapper.toEntity(responseDto.data!.apiKey);
  }

  @override
  Future<ApiKeyEntity> updateKey(String id, String name) async {
    final responseDto = await _remoteDataSource.updateKey(id, name);
    return ApiKeyMapper.toEntity(responseDto.data!.apiKey);
  }

  @override
  Future<void> deleteKey(String id) async {
    await _remoteDataSource.deleteKey(id);
  }

  @override
  Future<ApiKeyEntity> revokeKey(String id) async {
    final responseDto = await _remoteDataSource.revokeKey(id);
    if (responseDto.data == null) {
      // If backend doesn't return data, we might need to fetch it or handle it.
      // But with our backend fix, this shouldn't happen.
      throw Exception("Gagal mendapatkan data API Key setelah revoke");
    }

    return ApiKeyMapper.toEntity(responseDto.data!.apiKey);
  }

  @override
  Future<ApiKeyEntity> rotateKey(String id) async {
    final responseDto = await _remoteDataSource.rotateKey(id);
    return ApiKeyMapper.toEntity(responseDto.data!.apiKey);
  }

  @override
  Future<ApiKeyEntity> getKeyDetail(String id) async {
    final responseDto = await _remoteDataSource.getKeyDetail(id);
    return ApiKeyMapper.toEntity(responseDto.data!.apiKey);
  }
}

final apiKeyRepositoryProvider = Provider<ApiKeyRepository>((ref) {
  final remoteDataSource = ref.read(apiKeyRemoteDataSourceProvider);
  return ApiKeyRepositoryImpl(remoteDataSource);
});
