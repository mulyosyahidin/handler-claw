import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/providers/auth_session_provider.dart';
import 'package:handlerclaw/features/auth/presentation/login_controller.dart';
import 'package:handlerclaw/features/home/presentation/home_controller.dart';
import 'package:handlerclaw/features/home/presentation/widgets/app_drawer.dart';
import 'package:handlerclaw/shared/themes/app_text_styles.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authSession = ref.watch(authSessionProvider);
    final userName = authSession.value?.userDto?.name ?? 'Claw Master';

    final overviewAsync = ref.watch(homeControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('HandlerClaw', style: AppTextStyles.title()),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(homeControllerProvider.notifier).refresh(),
          ),
        ],
      ),
      drawer: AppDrawer(
        onLogout: () => ref.read(loginControllerProvider).logout(),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(homeControllerProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Text('Welcome back, $userName!', style: AppTextStyles.hero()),
              const SizedBox(height: 8),
              Text(
                'The claw is sharp and ready for your commands. (Or mostly just waiting for coffee)',
                style: AppTextStyles.body(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),

              // Summary Grid
              Text(
                'System Status (Real This Time)',
                style: AppTextStyles.heading(),
              ),
              const SizedBox(height: 16),
              overviewAsync.when(
                data: (overview) => GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _SummaryCard(
                      title: 'WA Logs',
                      value: overview.totalWhatsappLogs.toString(),
                      subtitle: 'Global messages',
                      icon: Icons.chat_bubble_outline,
                      color: Colors.blue,
                    ),
                    _SummaryCard(
                      title: 'Prayer Logs',
                      value: overview.totalPrayerLogs.toString(),
                      subtitle: 'Your spiritual stats',
                      icon: Icons.mosque_outlined,
                      color: Colors.green,
                    ),
                    _SummaryCard(
                      title: 'Reminder Hooks',
                      value: overview.totalReminderHooks.toString(),
                      subtitle: 'Active automations',
                      icon: Icons.webhook,
                      color: Colors.orange,
                    ),
                    _SummaryCard(
                      title: 'Your Devices',
                      value: overview.totalDevices.toString(),
                      subtitle: 'Registered gadgets',
                      icon: Icons.devices,
                      color: Colors.purple,
                    ),
                  ],
                ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'Failed to load stats: $err',
                      style: AppTextStyles.body(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Quick Actions
              Text('Quick Desperate Actions', style: AppTextStyles.heading()),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _ActionChip(
                      label: 'Feed the Claw',
                      icon: Icons.cookie,
                      onTap: () => _showMessage(
                        context,
                        'Nom nom nom! The claw is satisfied... for now.',
                      ),
                    ),
                    _ActionChip(
                      label: 'Panic Mode',
                      icon: Icons.warning_amber_rounded,
                      onTap: () => _showMessage(
                        context,
                        'AHHHHHHH! Keep calm and carry on.',
                      ),
                    ),
                    _ActionChip(
                      label: 'Do Magic',
                      icon: Icons.auto_fix_high,
                      onTap: () => _showMessage(
                        context,
                        '✨ Magic happened! (Actually just a toast)',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTextStyles.body(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const Spacer(),
          Text(value, style: AppTextStyles.heading(color: color)),
          Text(title, style: AppTextStyles.body(fontWeight: FontWeight.bold)),
          Text(
            subtitle,
            style: AppTextStyles.label(fontSize: 8, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.primaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.body(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
