import 'package:handlerclaw/core/domain/entities/user_entity.dart';

class AuthResult {
  final bool success;
  final String message;
  final UserEntity? user;
  final String? accessToken;

  AuthResult({
    required this.success,
    required this.message,
    this.user,
    this.accessToken,
  });
}
