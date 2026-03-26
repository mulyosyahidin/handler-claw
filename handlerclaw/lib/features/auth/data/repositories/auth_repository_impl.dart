import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/auth/token_storage.dart';
import 'package:handlerclaw/core/domain/entities/user_entity.dart';
import 'package:handlerclaw/features/auth/domain/entities/auth_result.dart';
import 'package:handlerclaw/features/auth/domain/repositories/auth_repository.dart';
import 'package:handlerclaw/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:handlerclaw/core/data/mappers/user_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  AuthRepositoryImpl(this.remoteDataSource, this.tokenStorage);

  @override
  Future<AuthResult> login(String email, String password) async {
    final response = await remoteDataSource.login(email, password);
    
    if (response.success && response.data != null) {
      final loginData = response.data!;
      return AuthResult(
        success: true,
        message: response.message,
        user: UserMapper.fromDto(loginData.user),
        accessToken: loginData.accessToken,
      );
    }
    
    return AuthResult(
      success: false,
      message: response.message,
    );
  }

  @override
  Future<UserEntity?> getMe() async {
    final response = await remoteDataSource.getMe();
    
    if (response.success && response.data != null) {
      return UserMapper.fromDto(response.data!.user);
    }
    
    return null;
  }

  @override
  Future<void> logout() async {
    await tokenStorage.clear();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.read(authRemoteDataSourceProvider);
  final tokenStorage = ref.read(tokenStorageProvider);
  return AuthRepositoryImpl(remoteDataSource, tokenStorage);
});
