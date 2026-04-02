import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/app/app_router.dart';
import 'package:handlerclaw/firebase_options.dart';
import 'package:handlerclaw/core/theme/app_theme.dart';
import 'package:handlerclaw/core/services/fcm_handler.dart';
import 'package:handlerclaw/features/notifications/application/pending_notification_provider.dart';
import 'package:handlerclaw/core/providers/auth_session_provider.dart';
import 'package:handlerclaw/app/navigation_keys.dart';
import 'package:handlerclaw/core/utils/logger.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:home_widget/home_widget.dart';
import 'dart:async';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // if (kDebugMode) {
  //   await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  // }

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  StreamSubscription? _widgetClickSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fcmHandlerProvider).init();
      _checkInitialWidgetClick();
    });

    _widgetClickSubscription = HomeWidget.widgetClicked.listen((uri) {
      _handleWidgetClick(uri);
    });
  }

  @override
  void dispose() {
    _widgetClickSubscription?.cancel();
    super.dispose();
  }

  void _checkInitialWidgetClick() async {
    final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    if (uri != null) {
      _handleWidgetClick(uri);
    }
  }

  void _handleWidgetClick(Uri? uri) {
    if (uri == null) return;
    Logger.info("HomeWidget clicked with URI: $uri");
    if (uri.scheme == 'handlerclaw' && (uri.host == 'add-log' || uri.path == '/add-log')) {
      final context = rootNavigatorKey.currentContext;
      if (context != null && context.mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (context.mounted) {
            context.push(Routes.addLog);
          }
        });
      }
    }
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
