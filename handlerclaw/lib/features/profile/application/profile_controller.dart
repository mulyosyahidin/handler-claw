import 'dart:async';
import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/providers/auth_session_provider.dart';
import 'package:handlerclaw/core/data/mappers/user_mapper.dart';
import 'package:handlerclaw/core/data/repositories/file_repository.dart';
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
      FirebaseCrashlytics.instance.recordError(
        e,
        st,
        reason: 'ProfileController.updateProfile',
      );
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
      FirebaseCrashlytics.instance.recordError(
        e,
        st,
        reason: 'ProfileController.updatePassword',
      );
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<ProfileUpdateResponseDto> updateAvatar(File imageFile) async {
    state = const AsyncLoading();

    try {
      // 1. Upload the file
      final uploadResponse =
          await ref.read(fileRepositoryProvider).uploadFile(imageFile);

      if (!uploadResponse.success || uploadResponse.data == null) {
        throw Exception(uploadResponse.message);
      }

      final avatarPath = uploadResponse.data!.file.filePath;

      // 2. Update profile with the new avatar path
      final response = await _repository.updateAvatar(avatarUrl: avatarPath);

      if (response.success && response.data != null) {
        // 3. Update session
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
      FirebaseCrashlytics.instance.recordError(
        e,
        st,
        reason: 'ProfileController.updateAvatar',
      );
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, void>(
  ProfileController.new,
);
