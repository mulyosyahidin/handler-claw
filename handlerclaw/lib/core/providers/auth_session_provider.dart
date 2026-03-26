import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/auth/auth_service.dart';

final authSessionProvider =
    AsyncNotifierProvider<AuthSessionController, AuthSession>(
      AuthSessionController.new,
    );
