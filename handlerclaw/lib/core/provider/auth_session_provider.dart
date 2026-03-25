import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/auth/auth_session.dart';
import 'package:handlerclaw/core/auth/auth_session_controller.dart';

final authSessionProvider =
    AsyncNotifierProvider<AuthSessionController, AuthSession>(
      AuthSessionController.new,
    );
