import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/prayer-logs/data/dto/prayer_log_dto.dart';
import 'package:handlerclaw/features/prayer-logs/applications/prayer_log_list_controller.dart';
import 'package:handlerclaw/features/prayer-logs/presentation/widgets/date_type_filter.dart';
import 'package:handlerclaw/features/prayer-logs/presentation/widgets/empty_state_page.dart';
import 'package:handlerclaw/shared/presentation/widgets/error_full_page.dart';
import 'package:handlerclaw/shared/themes/app_text_styles.dart';
import 'package:intl/intl.dart';

class JournalTab extends ConsumerWidget {
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final Future<void> Function() selectDateRange;

  const JournalTab({
    super.key,
    required this.scrollController,
    required this.onRefresh,
    required this.selectDateRange,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(prayerLogListControllerProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return state.when(
      data: (logsState) {
        return Column(
          children: [
            DateTypeFilter(
              selectedType: logsState.dateType,
              startDate: logsState.startDate,
              endDate: logsState.endDate,
              onTypeChanged: (type) {
                if (type == 'custom') {
                  selectDateRange();
                } else {
                  ref
                      .read(prayerLogListControllerProvider.notifier)
                      .updateFilter(dateType: type, start: null, end: null);
                }
              },
            ),
            Expanded(
              child: logsState.items.isEmpty
                  ? EmptyStatePage()
                  : RefreshIndicator(
                      onRefresh: onRefresh,
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        itemCount:
                            logsState.items.length +
                            (logsState.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == logsState.items.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          final log = logsState.items[index];
                          return _PrayerLogCard(log: log);
                        },
                      ),
                    ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          ErrorFullPage(message: error.toString(), onRefresh: onRefresh),
    );
  }
}

class _PrayerLogCard extends StatelessWidget {
  final PrayerLogDto log;

  const _PrayerLogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Color prayerColor = _getPrayerColor(log.prayer, colorScheme);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Indicator bar
              Container(width: 6, color: prayerColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                log.prayer,
                                style: AppTextStyles.title(
                                  fontSize: 18,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                DateFormat(
                                  'EEEE, d MMMM yyyy',
                                  'id_ID',
                                ).format(log.date),
                                style: AppTextStyles.label(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          _StatusBadge(log: log),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _InfoChip(
                            icon: Icons.access_time_rounded,
                            label: DateFormat(
                              'HH:mm',
                            ).format(log.performedAt.toLocal()),
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 12),
                          _InfoChip(
                            icon: Icons.location_on_rounded,
                            label: log.place,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 12),
                          _InfoChip(
                            icon: Icons.people_rounded,
                            label: log.method,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                      if (log.notes != null && log.notes!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.sticky_note_2_rounded,
                                size: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  log.notes!,
                                  style: AppTextStyles.body(
                                    fontSize: 13,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPrayerColor(String prayer, ColorScheme colorScheme) {
    switch (prayer.toUpperCase()) {
      case 'SUBUH':
        return Colors.blue;
      case 'DZUHUR':
      case 'JUMAT':
        return Colors.orange;
      case 'ASHAR':
        return Colors.amber;
      case 'MAGHRIB':
        return Colors.redAccent;
      case 'ISYA':
        return Colors.indigo;
      default:
        return colorScheme.primary;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final PrayerLogDto log;

  const _StatusBadge({required this.log});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bool isWajib = log.category.toUpperCase() == 'WAJIB';
    final Color badgeColor = isWajib
        ? colorScheme.primary
        : colorScheme.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor.withValues(alpha: 0.2)),
      ),
      child: Text(
        log.category,
        style: TextStyle(
          color: badgeColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color.withValues(alpha: 0.6)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: 0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
