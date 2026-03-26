import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/providers/auth_session_provider.dart';
import 'package:handlerclaw/features/auth/presentation/login_controller.dart';
import 'package:handlerclaw/features/home/presentation/home_controller.dart';
import 'package:handlerclaw/features/home/presentation/widgets/app_drawer.dart';
import 'package:handlerclaw/features/home/presentation/widgets/prayer_chip.dart';
import 'package:handlerclaw/features/home/presentation/widgets/summary_card.dart';
import 'package:handlerclaw/features/prayer-logs/applications/today_prayer_controller.dart';
import 'package:handlerclaw/shared/themes/app_text_styles.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authSession = ref.watch(authSessionProvider);
    final userName = authSession.value?.userDto?.name ?? 'Claw Master';

    final overviewAsync = ref.watch(homeControllerProvider);
    final todayPrayersAsync = ref.watch(todayPrayerControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('HandlerClaw', style: AppTextStyles.title()),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(homeControllerProvider.notifier).refresh();
              ref.read(todayPrayerControllerProvider.notifier).refresh();
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
          await ref.read(todayPrayerControllerProvider.notifier).refresh();
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
                data: (overview) => GridView.count(
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
                      title: 'Reminder Hooks',
                      value: overview.totalReminderHooks.toString(),
                      subtitle: 'Active automations',
                      icon: Icons.webhook,
                      color: Colors.orange,
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
                loading: () => GridView.count(
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
                      title: 'Reminder Hooks',
                      subtitle: 'Active automations',
                      icon: Icons.webhook,
                      color: Colors.orange,
                    ),
                    SummaryCardSkeleton(
                      title: 'Your Devices',
                      subtitle: 'Registered gadgets',
                      icon: Icons.devices,
                      color: Colors.purple,
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
              const SizedBox(height: 32),

              // Today's Prayer Status
              Text('Jurnal Solat Hari Ini', style: AppTextStyles.heading()),
              const SizedBox(height: 16),
              todayPrayersAsync.when(
                data: (todaySummary) {
                  if (todaySummary == null || todaySummary.byPrayer.isEmpty) {
                    return Text(
                      'No prayer logs for today yet.',
                      style: AppTextStyles.body(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    );
                  }

                  // Define mandatory prayers based on the day of the week
                  final isFriday = DateTime.now().weekday == DateTime.friday;
                  final mandatoryPrayers = [
                    'SUBUH',
                    if (isFriday) 'JUMAT' else 'DZUHUR',
                    'ASHAR',
                    'MAGHRIB',
                    'ISYA',
                  ];

                  // Filter and sort prayers based on mandatory list
                  final displayedPrayers = mandatoryPrayers
                      .where((p) => todaySummary.byPrayer.containsKey(p))
                      .toList();

                  return SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: displayedPrayers.map((prayerName) {
                        return PrayerChip(
                          prayerName: prayerName,
                          detail: todaySummary.byPrayer[prayerName]!,
                        );
                      }).toList(),
                    ),
                  );
                },
                loading: () => SizedBox(
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
                error: (err, stack) => Text(
                  'Failed to load prayer status',
                  style: AppTextStyles.body(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
