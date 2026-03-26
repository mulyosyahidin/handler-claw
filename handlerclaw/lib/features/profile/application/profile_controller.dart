import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/providers/auth_session_provider.dart';
import 'package:handlerclaw/core/data/mappers/user_mapper.dart';
import 'package:handlerclaw/features/profile/data/responses/password_update_response_dto.dart';
import 'package:handlerclaw/features/profile/data/responses/profile_update_response_dto.dart';
import 'package:handlerclaw/features/profile/domain/repositories/profile_repository.dart';
import 'package:handlerclaw/features/profile/data/repositories/profile_repository_impl.dart';

class ProfileController extends AsyncNotifier<void> {
  ProfileRepository get _repository => ref.read(profileRepositoryProvider);

  @override
  FutureOr<void> build() {}

  Future<ProfileUpdateResponseDto> updateProfile({
    required String name,
    required String email,
  }) async {
    state = const AsyncLoading();
    
    try {
      final response = await _repository.updateProfile(
        name: name,
        email: email,
      );

      if (response.success && response.data != null) {
        // Update session
        final session = ref.read(authSessionProvider).value;
        if (session?.token != null) {
          await ref.read(authSessionProvider.notifier).setSession(
                session!.token!,
                UserMapper.fromDto(response.data!.user),
              );
        }
      }

      state = const AsyncData(null);
      return response;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<PasswordUpdateResponseDto> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    state = const AsyncLoading();

    try {
      final response = await _repository.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
      );

      state = const AsyncData(null);
      return response;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, void>(
  ProfileController.new,
);
