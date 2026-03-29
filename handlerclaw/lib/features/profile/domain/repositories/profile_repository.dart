import 'package:handlerclaw/features/profile/data/responses/password_update_response_dto.dart';
import 'package:handlerclaw/features/profile/data/responses/profile_update_response_dto.dart';

abstract class ProfileRepository {
  Future<ProfileUpdateResponseDto> updateProfile({
    required String name,
    required String email,
  });

  Future<PasswordUpdateResponseDto> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  });

  Future<ProfileUpdateResponseDto> updateAvatar({
    required String avatarUrl,
  });
}
