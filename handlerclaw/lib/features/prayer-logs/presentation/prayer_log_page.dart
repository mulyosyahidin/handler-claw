import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/prayer-logs/applications/prayer_log_list_controller.dart';
import 'package:handlerclaw/features/prayer-logs/applications/prayer_log_summary_controller.dart';
import 'package:handlerclaw/features/prayer-logs/presentation/screens/journal_tab.dart';
import 'package:handlerclaw/features/prayer-logs/presentation/screens/summary_tab.dart';
import 'package:handlerclaw/shared/themes/app_text_styles.dart';

class PrayerLogPage extends ConsumerStatefulWidget {
  const PrayerLogPage({super.key});

  @override
  ConsumerState<PrayerLogPage> createState() => _PrayerLogPageState();
}

class _PrayerLogPageState extends ConsumerState<PrayerLogPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(prayerLogListControllerProvider.notifier).loadMore();
    }
  }

  Future<void> _refresh() async {
    final listRefresh = ref
        .read(prayerLogListControllerProvider.notifier)
        .refresh();
    final summaryRefresh = ref
        .read(prayerLogSummaryControllerProvider.notifier)
        .refresh();
    await Future.wait([listRefresh, summaryRefresh]);
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final state = ref.read(prayerLogListControllerProvider).value;
    final initialDateRange =
        (state?.startDate != null && state?.endDate != null)
        ? DateTimeRange(start: state!.startDate!, end: state.endDate!)
        : null;

    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(onPrimary: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ref
          .read(prayerLogListControllerProvider.notifier)
          .updateFilter(
            dateType: 'custom',
            start: picked.start,
            end: picked.end,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(prayerLogListControllerProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Jurnal Solat', style: AppTextStyles.title()),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _refresh,
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Jurnal'),
              Tab(text: 'Ringkasan'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            JournalTab(
              scrollController: _scrollController,
              onRefresh: _refresh,
              selectDateRange: () => _selectDateRange(context),
            ),
            SummaryTab(selectDateRange: () => _selectDateRange(context)),
          ],
        ),
      ),
    );
  }
}
