import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/prayer-logs/applications/prayer_log_summary_controller.dart';
import 'package:handlerclaw/features/prayer-logs/presentation/widgets/date_type_filter.dart';
import 'package:handlerclaw/shared/presentation/widgets/error_full_page.dart';
import 'package:handlerclaw/shared/themes/app_text_styles.dart';

class SummaryTab extends ConsumerWidget {
  final Future<void> Function() selectDateRange;

  const SummaryTab({super.key, required this.selectDateRange});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(prayerLogSummaryControllerProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final summaryState = state.asData?.value;
    final isLoading = state.isLoading;

    if (summaryState == null && isLoading) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildSummaryCard(
                  title: 'Subuh',
                  count: 0,
                  isLoading: true,
                  color: Colors.blue,
                  context: context,
                ),
                _buildSummaryCard(
                  title: 'Dzuhur',
                  count: 0,
                  isLoading: true,
                  color: Colors.orange,
                  context: context,
                ),
                _buildSummaryCard(
                  title: 'Ashar',
                  count: 0,
                  isLoading: true,
                  color: Colors.amber,
                  context: context,
                ),
                _buildSummaryCard(
                  title: 'Maghrib',
                  count: 0,
                  isLoading: true,
                  color: Colors.redAccent,
                  context: context,
                ),
                _buildSummaryCard(
                  title: 'Isya',
                  count: 0,
                  isLoading: true,
                  color: Colors.indigo,
                  context: context,
                ),
                _buildSummaryCard(
                  title: 'Jumat',
                  count: 0,
                  isLoading: true,
                  color: Colors.teal,
                  context: context,
                ),
                _buildSummaryCard(
                  title: 'Dhuha',
                  count: 0,
                  isLoading: true,
                  color: Colors.pinkAccent,
                  context: context,
                ),
                _buildSummaryCard(
                  title: 'Tahajud',
                  count: 0,
                  isLoading: true,
                  color: Colors.deepPurple,
                  context: context,
                ),
                _buildSummaryCard(
                  title: 'Witir',
                  count: 0,
                  isLoading: true,
                  color: Colors.cyan,
                  context: context,
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (state.hasError && summaryState == null) {
      return ErrorFullPage(
        message: state.error.toString(),
        onRefresh: () =>
            ref.read(prayerLogSummaryControllerProvider.notifier).refresh(),
      );
    }

    if (summaryState == null) {
      return const SizedBox.shrink();
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(prayerLogSummaryControllerProvider.notifier).refresh(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DateTypeFilter(
              selectedType: summaryState.dateType,
              startDate: summaryState.startDate,
              endDate: summaryState.endDate,
              onTypeChanged: (type) {
                if (type == 'custom') {
                  selectDateRange();
                } else {
                  ref
                      .read(prayerLogSummaryControllerProvider.notifier)
                      .updateFilter(dateType: type, start: null, end: null);
                }
              },
            ),

            const SizedBox(height: 16),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildSummaryCard(
                  title: 'Subuh',
                  count: summaryState.count.subuh,
                  percentage: summaryState.performance.subuh.percentage,
                  isLoading: isLoading,
                  color: Colors.blue,
                  context: context,
                ),
                _buildSummaryCard(
                  title: 'Dzuhur',
                  count: summaryState.count.dzuhur,
                  percentage: summaryState.performance.dzuhur.percentage,
                  isLoading: isLoading,
                  color: Colors.orange,
                  context: context,
                ),
                _buildSummaryCard(
                  title: 'Ashar',
                  count: summaryState.count.ashar,
                  percentage: summaryState.performance.ashar.percentage,
                  isLoading: isLoading,
                  color: Colors.amber,
                  context: context,
                ),
                _buildSummaryCard(
                  title: 'Maghrib',
                  count: summaryState.count.maghrib,
                  percentage: summaryState.performance.maghrib.percentage,
                  isLoading: isLoading,
                  color: Colors.redAccent,
                  context: context,
                ),
                _buildSummaryCard(
                  title: 'Isya',
                  count: summaryState.count.isya,
                  percentage: summaryState.performance.isya.percentage,
                  isLoading: isLoading,
                  color: Colors.indigo,
                  context: context,
                ),
                _buildSummaryCard(
                  title: 'Jumat',
                  count: summaryState.count.jumat,
                  percentage: summaryState.performance.jumat.percentage,
                  isLoading: isLoading,
                  color: Colors.teal,
                  context: context,
                ),
                _buildSummaryCard(
                  title: 'Dhuha',
                  count: summaryState.count.dhuha,
                  percentage: summaryState.performance.dhuha.percentage,
                  isLoading: isLoading,
                  color: Colors.pinkAccent,
                  context: context,
                ),
                _buildSummaryCard(
                  title: 'Tahajud',
                  count: summaryState.count.tahajud,
                  percentage: summaryState.performance.tahajud.percentage,
                  isLoading: isLoading,
                  color: Colors.deepPurple,
                  context: context,
                ),
                _buildSummaryCard(
                  title: 'Witir',
                  count: summaryState.count.witir,
                  percentage: summaryState.performance.witir.percentage,
                  isLoading: isLoading,
                  color: Colors.cyan,
                  context: context,
                ),
              ],
            ),
            const SizedBox(height: 24),

            if ([
              'today',
              'this_week',
              '7_days',
              'this_month',
              '30_days',
              'custom',
            ].contains(summaryState.dateType)) ...[
              Text(
                'Checklist Solat Wajib',
                style: AppTextStyles.heading(color: colorScheme.onSurface),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 24,
                      headingRowColor: WidgetStateProperty.all(
                        colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      columns: const [
                        DataColumn(label: Text('Tanggal')),
                        DataColumn(label: Text('Subuh')),
                        DataColumn(label: Text('Dzuhur')),
                        DataColumn(label: Text('Ashar')),
                        DataColumn(label: Text('Maghrib')),
                        DataColumn(label: Text('Isya')),
                      ],
                      rows: summaryState.summary.map((item) {
                        return DataRow(
                          cells: [
                            DataCell(Text(item.label)),
                            _buildChecklistCell(
                              item.byPrayer['SUBUH']?.performed ?? 0,
                              item.label,
                            ),
                            _buildChecklistCell(
                              (item.byPrayer['DZUHUR']?.performed ?? 0) +
                                  (item.byPrayer['JUMAT']?.performed ?? 0),
                              item.label,
                              isFridayJumat:
                                  (item.byPrayer['JUMAT']?.performed ?? 0) > 0,
                            ),
                            _buildChecklistCell(
                              item.byPrayer['ASHAR']?.performed ?? 0,
                              item.label,
                            ),
                            _buildChecklistCell(
                              item.byPrayer['MAGHRIB']?.performed ?? 0,
                              item.label,
                            ),
                            _buildChecklistCell(
                              item.byPrayer['ISYA']?.performed ?? 0,
                              item.label,
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required int count,
    double? percentage,
    bool isLoading = false,
    required Color color,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: (MediaQuery.of(context).size.width - 40) / 2 - 6,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(title, style: AppTextStyles.title(fontSize: 14)),
                ],
              ),
              const SizedBox(height: 12),
              if (isLoading)
                Container(
                  width: 60,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                )
              else
                Text(
                  '$count kali',
                  style: AppTextStyles.title(fontSize: 20, color: color),
                ),
              if (percentage != null) ...[
                const SizedBox(height: 4),
                if (isLoading)
                  Container(
                    width: 40,
                    height: 14,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )
                else
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: AppTextStyles.body(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  DataCell _buildChecklistCell(
    int performed,
    String dateStr, {
    bool isFridayJumat = false,
  }) {
    final date = DateTime.tryParse(dateStr);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isPast = date != null && date.isBefore(today);

    IconData icon;
    Color color;

    if (performed > 0) {
      icon = Icons.check_circle_rounded;
      color = isFridayJumat ? Colors.blue : Colors.green;
    } else if (isPast) {
      icon = Icons.cancel_rounded;
      color = Colors.red;
    } else {
      icon = Icons.radio_button_unchecked_rounded;
      color = Colors.grey.withValues(alpha: 0.5);
    }

    return DataCell(Center(child: Icon(icon, color: color, size: 20)));
  }
}
