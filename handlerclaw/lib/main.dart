import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/app/app_router.dart';
import 'package:handlerclaw/firebase_options.dart';
import 'package:handlerclaw/shared/themes/app_theme.dart';
import 'package:handlerclaw/core/notifications/fcm_handler.dart';
import 'package:handlerclaw/features/notification-detail/presentation/pending_notification_provider.dart';
import 'package:handlerclaw/core/providers/auth_session_provider.dart';
import 'package:handlerclaw/app/navigation_keys.dart';
import 'package:handlerclaw/shared/utils/logger.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fcmHandlerProvider).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    // Global listener for pending notifications
    ref.listen(pendingNotificationProvider, (previous, next) {
      if (next != null) {
        final session = ref.read(authSessionProvider);
        if (session.value?.isAuthenticated == true) {
          final context = rootNavigatorKey.currentContext;
          if (context != null && context.mounted) {
            Logger.info(
              "Global Navigating to pending notification afterdetail: $next",
            );
            context.push(Routes.notificationDetail.replaceAll(':id', next));
            ref
                .read(pendingNotificationProvider.notifier)
                .setNotification(null);
          }
        }
      }
    });

    // Also listen to authSessionProvider for pending notifications after login
    ref.listen(authSessionProvider, (previous, next) {
      if (next.value?.isAuthenticated == true) {
        final pendingId = ref.read(pendingNotificationProvider);
        if (pendingId != null) {
          final context = rootNavigatorKey.currentContext;
          if (context != null && context.mounted) {
            Logger.info(
              "Global Navigating to pending notification after Auth: $pendingId",
            );
            context.push(
              Routes.notificationDetail.replaceAll(':id', pendingId),
            );
            ref
                .read(pendingNotificationProvider.notifier)
                .setNotification(null);
          }
        }
      }
    });

    return MaterialApp.router(
      routerConfig: router,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
    );
  }
}
