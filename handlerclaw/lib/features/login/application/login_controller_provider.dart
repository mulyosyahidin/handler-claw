import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/login/application/login_controller.dart';

final loginControllerProvider = Provider<LoginController>((ref) {
  return LoginController(ref);
});