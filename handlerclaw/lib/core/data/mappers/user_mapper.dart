import 'package:handlerclaw/core/domain/entities/user_entity.dart';
import 'package:handlerclaw/core/data/dto/user_dto.dart';

class UserMapper {
  static UserEntity fromDto(UserDto dto) {
    return UserEntity(
      id: dto.id,
      name: dto.name,
      email: dto.email,
      lastLoginAt: dto.lastLoginAt,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  static UserDto toDto(UserEntity entity) {
    return UserDto(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      lastLoginAt: entity.lastLoginAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
