import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/app/app_router.dart';
import 'package:handlerclaw/core/provider/fcm_message_handler_provider.dart';
import 'package:handlerclaw/core/provider/local_notification_service_provider.dart';
import 'package:handlerclaw/core/utils/logger.dart';
import 'package:handlerclaw/firebase_options.dart';
import 'package:handlerclaw/shared/theme/app_theme.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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

    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    // Inisialisasi local notifications
    final localNotificationService = ref.read(localNotificationServiceProvider);
    await localNotificationService.initialize();

    // Setup FCM message handler untuk foreground
    final fcmMessageHandler = ref.read(fcmMessageHandlerProvider);
    fcmMessageHandler.initialize();

    // Request permission untuk iOS (Android tidak perlu)
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Log FCM token untuk debug
    final token = await messaging.getToken();
    Logger.info('[FCM] Token: $token');
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      routerConfig: router,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
    );
  }
}
