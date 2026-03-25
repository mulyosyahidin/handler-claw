import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/provider/auth_session_provider.dart';

final tokenProvider = Provider<Future<String?> Function()>((ref) {
  return () async {
    final sessionAsync = ref.read(authSessionProvider);

    return sessionAsync.when(
      data: (session) => session.token,
      loading: () => null,
      error: (_, _) => null,
    );
  };
});
