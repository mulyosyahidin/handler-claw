import 'package:handlerclaw/features/api-keys/data/dto/api_key_dto.dart';
import 'package:handlerclaw/features/api-keys/domain/entities/api_key_entity.dart';

class ApiKeyMapper {
  static ApiKeyEntity toEntity(ApiKeyDto dto) {
    return ApiKeyEntity(
      id: dto.id,
      name: dto.name,
      keyPreview: dto.keyPreview,
      status: _mapStatus(dto.status),
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
      plainKey: dto.plainKey,
    );
  }

  static ApiKeyStatus _mapStatus(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return ApiKeyStatus.ACTIVE;
      case 'REVOKED':
        return ApiKeyStatus.REVOKED;
      case 'EXPIRED':
        return ApiKeyStatus.EXPIRED;
      default:
        return ApiKeyStatus.ACTIVE;
    }
  }
}
