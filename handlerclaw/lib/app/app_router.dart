import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:handlerclaw/app/navigation_keys.dart';
import 'package:handlerclaw/app/routes.dart';
import 'package:handlerclaw/core/provider/auth_session_provider.dart';
import 'package:handlerclaw/features/home/presentation/home_page.dart';
import 'package:handlerclaw/features/login/presentation/login_page.dart';
import 'package:handlerclaw/features/notification-detail/presentation/notification_detail_page.dart';
import 'package:handlerclaw/core/data/dto/notification_dto.dart';
import 'package:handlerclaw/features/splash/presentation/splash_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(authSessionProvider);

  return GoRouter(
    initialLocation: Routes.splash,
    navigatorKey: rootNavigatorKey,
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: Routes.notificationDetail,
        builder: (context, state) {
          final data = state.extra as NotificationDto;
          return NotificationDetailPage(data: data);
        },
      ),
    ],
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isOnSplashPage = location == Routes.splash;

      if (session.isLoading) {
        return isOnSplashPage ? null : Routes.splash;
      }

      final isLoggedIn = session.maybeWhen(
        data: (auth) => auth.isAuthenticated,
        orElse: () => false,
      );

      if (isOnSplashPage) {
        return isLoggedIn ? Routes.home : Routes.login;
      }

      if (!isLoggedIn && location != Routes.login) return Routes.login;
      if (isLoggedIn && location == Routes.login) return Routes.home;

      return null;
    },
  );
});
