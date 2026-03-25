import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:handlerclaw/app/app_router.dart';
import 'package:handlerclaw/core/notification/pending_notification_provider.dart';
import 'package:handlerclaw/core/provider/auth_session_provider.dart';
import 'package:handlerclaw/features/auth/presentation/login_controller.dart';
import 'package:handlerclaw/features/home/presentation/widgets/app_drawer.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    final user = session.value?.userDto;

    // Check for pending notification
    final pendingId = ref.watch(pendingNotificationProvider);
    if (pendingId != null && session.value?.isAuthenticated == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.push(Routes.notificationDetail.replaceAll(':id', pendingId));
          // Clear it
          ref.read(pendingNotificationProvider.notifier).setNotification(null);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'HandlerClaw',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 20,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.8,
          ),
        ),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
      ),
      drawer: AppDrawer(
        name: user?.name ?? 'User',
        email: user?.email ?? '',
        onLogout: () => ref.read(loginControllerProvider).logout(),
      ),
      body: const Center(child: Text('Home Content Here')),
    );
  }
}
