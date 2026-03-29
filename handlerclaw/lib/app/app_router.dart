import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:handlerclaw/app/navigation_keys.dart';
import 'package:handlerclaw/core/config/env.dart';
import 'package:handlerclaw/core/providers/auth_session_provider.dart';
import 'package:handlerclaw/features/auth/presentation/screens/login_page.dart';
import 'package:handlerclaw/features/devices/presentation/screens/devices_page.dart';
import 'package:handlerclaw/features/home/presentation/screens/home_page.dart';
import 'package:handlerclaw/features/notifications/domain/entities/notification_entity.dart';
import 'package:handlerclaw/features/notifications/presentation/screens/notification_detail_page.dart';
import 'package:handlerclaw/features/notifications/presentation/screens/notification_list_page.dart';
import 'package:handlerclaw/features/profile/presentation/screens/profile_page.dart';
import 'package:handlerclaw/features/splash/presentation/screens/splash_page.dart';
import 'package:handlerclaw/features/prayer-logs/presentation/screens/prayer_log_page.dart';
import 'package:handlerclaw/features/prayer-logs/presentation/screens/add_prayer_log_page.dart';
import 'package:handlerclaw/features/whatsapp-logs/presentation/screens/whatsapp_logs_page.dart';
import 'package:handlerclaw/features/debug/presentation/screens/debug_page.dart';
import 'package:handlerclaw/core/utils/logger.dart';

class Routes {
  static const splash = "/splash";
  static const login = "/login";
 
  static const home = "/home";
  static const profile = "/profile";
 
  static const notificationDetail = "/notification-detail/:id";
  static const notificationList = "/notifications";
  static const whatsappLogs = "/whatsapp-logs";
  static const prayerLogs = "/prayer-logs";
  static const devices = "/devices";
  static const addLog = "/add-log";
  static const debug = "/debug";
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
          final data = state.extra as NotificationEntity?;
          return NotificationDetailPage(id: id, data: data);
        },
      ),
      GoRoute(
        path: Routes.whatsappLogs,
        builder: (context, state) => const WhatsAppLogsPage(),
      ),
      GoRoute(
        path: Routes.prayerLogs,
        builder: (context, state) => const PrayerLogPage(),
      ),
      GoRoute(
        path: Routes.devices,
        builder: (context, state) => const DevicesPage(),
      ),
      GoRoute(
        path: Routes.addLog,
        builder: (context, state) {
          final prayer = state.extra as String?;
          return AddPrayerLogPage(initialPrayer: prayer);
        },
      ),
      GoRoute(
        path: Routes.debug,
        builder: (context, state) => const DebugPage(),
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
    
    // Prevent access to debug page if it's disabled in Env
    if (location == Routes.debug && !Env.showDebugPage) {
      return Routes.home;
    }

    return null;
  }
}
