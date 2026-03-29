import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:handlerclaw/features/profile/data/responses/password_update_response_dto.dart';
import 'package:handlerclaw/features/profile/data/responses/profile_update_response_dto.dart';
import 'package:handlerclaw/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<ProfileUpdateResponseDto> updateProfile({
    required String name,
    required String email,
  }) async {
    return await _remoteDataSource.updateProfile(
      name: name,
      email: email,
    );
  }

  @override
  Future<PasswordUpdateResponseDto> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    return await _remoteDataSource.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmNewPassword: confirmNewPassword,
    );
  }

  @override
  Future<ProfileUpdateResponseDto> updateAvatar({
    required String avatarUrl,
  }) async {
    return await _remoteDataSource.updateAvatar(
      avatarUrl: avatarUrl,
    );
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final remoteDataSource = ref.read(profileRemoteDataSourceProvider);
  return ProfileRepositoryImpl(remoteDataSource);
});
