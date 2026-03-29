import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/providers/auth_session_provider.dart';
import 'package:handlerclaw/features/auth/application/login_controller.dart';
import 'package:handlerclaw/features/home/domain/entities/home_overview_entity.dart';
import 'package:handlerclaw/features/home/application/home_controller.dart';
import 'package:handlerclaw/features/home/presentation/widgets/app_drawer.dart';
import 'package:handlerclaw/features/home/presentation/widgets/prayer_chip.dart';
import 'package:handlerclaw/features/home/presentation/widgets/summary_card.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authSession = ref.watch(authSessionProvider);
    final userName = authSession.value?.user?.name ?? 'Claw Master';

    final overviewAsync = ref.watch(homeControllerProvider);
 
    return Scaffold(
      appBar: AppBar(
        title: Text('HandlerClaw', style: AppTextStyles.title()),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(homeControllerProvider.notifier).refresh();
            },
          ),
        ],
      ),
      drawer: AppDrawer(
        onLogout: () => ref.read(loginControllerProvider).logout(),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(homeControllerProvider.notifier).refresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Text('Halo, $userName!', style: AppTextStyles.hero()),
              const SizedBox(height: 32),
 
              // Summary Grid
              Text('App Summary', style: AppTextStyles.heading()),
              const SizedBox(height: 16),
              overviewAsync.when(
                data: (HomeOverviewEntity overview) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.2,
                      children: [
                        SummaryCard(
                          title: 'WA Logs',
                          value: overview.totalWhatsappLogs.toString(),
                          subtitle: 'Global messages',
                          icon: Icons.chat_bubble_outline,
                          color: Colors.blue,
                        ),
                        SummaryCard(
                          title: 'Prayer Logs',
                          value: overview.totalPrayerLogs.toString(),
                          subtitle: 'Your spiritual stats',
                          icon: Icons.mosque_outlined,
                          color: Colors.green,
                        ),
                        SummaryCard(
                          title: 'Webhooks',
                          value: overview.totalReminderHooks.toString(),
                          subtitle: 'Active automations',
                          icon: Icons.webhook,
                          color: Colors.orange,
                        ),
                        SummaryCard(
                          title: 'Notifications',
                          value: overview.totalNotifications.toString(),
                          subtitle: 'Sent alerts',
                          icon: Icons.notifications_none_outlined,
                          color: Colors.redAccent,
                        ),
                        SummaryCard(
                          title: 'Your Devices',
                          value: overview.totalDevices.toString(),
                          subtitle: 'Registered gadgets',
                          icon: Icons.devices,
                          color: Colors.purple,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
 
                    // Today's Prayer Status (Inside Data)
                    Text('Jurnal Solat Hari Ini', style: AppTextStyles.heading()),
                    const SizedBox(height: 16),
                    if (overview.prayerStatus.isEmpty)
                      Text(
                        'No prayer logs for today yet.',
                        style: AppTextStyles.body(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: overview.prayerStatus.entries.map((entry) {
                            return PrayerChip(
                              prayerName: entry.key,
                              isPerformed: entry.value,
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
                loading: () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.2,
                      children: const [
                        SummaryCardSkeleton(
                          title: 'WA Logs',
                          subtitle: 'Global messages',
                          icon: Icons.chat_bubble_outline,
                          color: Colors.blue,
                        ),
                        SummaryCardSkeleton(
                          title: 'Prayer Logs',
                          subtitle: 'Your spiritual stats',
                          icon: Icons.mosque_outlined,
                          color: Colors.green,
                        ),
                        SummaryCardSkeleton(
                          title: 'Webhooks',
                          subtitle: 'Active automations',
                          icon: Icons.webhook,
                          color: Colors.orange,
                        ),
                        SummaryCardSkeleton(
                          title: 'Notifications',
                          subtitle: 'Sent alerts',
                          icon: Icons.notifications_none_outlined,
                          color: Colors.redAccent,
                        ),
                        SummaryCardSkeleton(
                          title: 'Your Devices',
                          subtitle: 'Registered gadgets',
                          icon: Icons.devices,
                          color: Colors.purple,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text('Jurnal Solat Hari Ini', style: AppTextStyles.heading()),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(
                          5,
                          (index) => const PrayerChipSkeleton(),
                        ),
                      ),
                    ),
                  ],
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
            ],
          ),
        ),
      ),
    );
  }
}
