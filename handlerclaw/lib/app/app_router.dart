import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:handlerclaw/app/navigation_keys.dart';
import 'package:handlerclaw/core/providers/auth_session_provider.dart';
import 'package:handlerclaw/features/auth/presentation/login_page.dart';
import 'package:handlerclaw/features/devices/presentation/devices_page.dart';
import 'package:handlerclaw/features/home/presentation/home_page.dart';
import 'package:handlerclaw/core/models/dto/notification_dto.dart';
import 'package:handlerclaw/features/notification-detail/presentation/notification_detail_page.dart';
import 'package:handlerclaw/features/notification-list/presentation/notification_list_page.dart';
import 'package:handlerclaw/features/profile/presentation/profile_page.dart';
import 'package:handlerclaw/features/splash/presentation/splash_page.dart';
import 'package:handlerclaw/features/whatsapp-logs/presentation/whatsapp_logs_page.dart';
import 'package:handlerclaw/shared/utils/logger.dart';

 
class Routes {
  static const splash = "/splash";
  static const login = "/login";
 
  static const home = "/home";
  static const profile = "/profile";
 
  static const notificationDetail = "/notification-detail/:id";
  static const notificationList = "/notifications";
  static const whatsappLogs = "/whatsapp-logs";
  static const devices = "/devices";
}
 
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);
 
  return GoRouter(
    initialLocation: Routes.splash,
    navigatorKey: rootNavigatorKey,
    refreshListenable: notifier,
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(path: Routes.home, builder: (context, state) => const HomePage()),
      GoRoute(
        path: Routes.profile,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: Routes.notificationList,
        builder: (context, state) => const NotificationListPage(),
      ),
      GoRoute(
        path: Routes.notificationDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final data = state.extra as NotificationDto?;
          return NotificationDetailPage(id: id, data: data);
        },
      ),
      GoRoute(
        path: Routes.whatsappLogs,
        builder: (context, state) => const WhatsAppLogsPage(),
      ),
      GoRoute(
        path: Routes.devices,
        builder: (context, state) => const DevicesPage(),
      ),
    ],
    redirect: notifier.redirect,
  );
});

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(
      authSessionProvider,
      (_, _) => notifyListeners(),
      fireImmediately: true,
    );
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final session = _ref.read(authSessionProvider);
    final location = state.matchedLocation;
    final isOnSplashPage = location == Routes.splash;

    if (session.isLoading) {
      return isOnSplashPage ? null : Routes.splash;
    }

    final isAuthenticated = session.maybeWhen(
      data: (auth) => auth.isAuthenticated,
      orElse: () => false,
    );

    Logger.info("isLoggedIn: $isAuthenticated");
    Logger.info(
      "Redirect Check: location=$location, authenticated=$isAuthenticated",
    );

    if (isOnSplashPage) {
      return isAuthenticated ? Routes.home : Routes.login;
    }

    if (!isAuthenticated && location != Routes.login) {
      return Routes.login;
    }
    if (isAuthenticated && location == Routes.login) return Routes.home;

    return null;
  }
}
