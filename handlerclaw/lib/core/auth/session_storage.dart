import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:handlerclaw/core/data/dto/user_dto.dart';

class SessionStorage {
  final _storage = const FlutterSecureStorage();

  static const _tokenKey = "auth_token";
  static const _userKey = "user_data";

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> saveUser(UserDto userDto) async {
    final jsonString = jsonEncode(userDto.toJson());

    await _storage.write(key: _userKey, value: jsonString);
  }

  Future<UserDto?> getUser() async {
    final jsonString = await _storage.read(key: _userKey);

    if (jsonString == null) return null;

    final Map<String, dynamic> json = jsonDecode(jsonString);

    return UserDto.fromJson(json);
  }

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }
}
