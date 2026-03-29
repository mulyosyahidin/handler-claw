import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:handlerclaw/core/providers/secure_storage_provider.dart';
import 'package:handlerclaw/core/data/dto/user_dto.dart';
import 'package:handlerclaw/core/domain/entities/user_entity.dart';
import 'package:handlerclaw/core/data/mappers/user_mapper.dart';

class TokenStorage {
  final FlutterSecureStorage _storage;

  TokenStorage(this._storage);

  static const _tokenKey = "auth_token";
  static const _userKey = "user_data";

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> saveUser(UserEntity user) async {
    final userDto = UserMapper.toDto(user);
    final jsonString = jsonEncode(userDto.toJson());

    await _storage.write(key: _userKey, value: jsonString);
  }

  Future<UserEntity?> getUser() async {
    final jsonString = await _storage.read(key: _userKey);

    if (jsonString == null) return null;

    final Map<String, dynamic> json = jsonDecode(jsonString);

    final dto = UserDto.fromJson(json);
    return UserMapper.fromDto(dto);
  }

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }
}

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return TokenStorage(storage);
});
