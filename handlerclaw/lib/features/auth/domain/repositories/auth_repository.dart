import 'package:handlerclaw/core/domain/entities/user_entity.dart';
import 'package:handlerclaw/features/auth/domain/entities/auth_result.dart';

abstract class AuthRepository {
  Future<AuthResult> login(String email, String password);
  Future<void> logout();
  Future<UserEntity?> getMe();
}
