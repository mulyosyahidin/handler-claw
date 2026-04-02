import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';
import 'package:handlerclaw/features/finances/application/finance_controller.dart';
import 'package:handlerclaw/features/finances/domain/entities/finance_overview_entity.dart';
import 'package:handlerclaw/features/finances/presentation/widgets/dashboard/account_list_section.dart';
import 'package:handlerclaw/features/finances/presentation/widgets/dashboard/account_type_list_section.dart';
import 'package:handlerclaw/features/finances/presentation/widgets/dashboard/finance_summary_grid.dart';
import 'package:handlerclaw/features/finances/presentation/widgets/dashboard/net_worth_card.dart';
import 'package:handlerclaw/features/finances/presentation/widgets/dashboard/top_movers_list_section.dart';

class FinanceDashboardPage extends ConsumerWidget {
  const FinanceDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financeAsync = ref.watch(financeControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Keuangan', style: AppTextStyles.title()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.read(financeControllerProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: financeAsync.when(
        data: (finance) => _buildContent(
          context,
          ref,
          finance,
          isLoading: financeAsync.isRefreshing,
        ),
        loading: () => _buildContent(
          context,
          ref,
          null, // No data yet, show full layout skeletons
          isLoading: true,
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $err', style: AppTextStyles.body(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(financeControllerProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    FinanceOverviewEntity? finance, {
    required bool isLoading,
  }) {
    return RefreshIndicator(
      onRefresh: () => ref.read(financeControllerProvider.notifier).refresh(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NetWorthCard(
              netWorth: finance?.totalNetWorth,
              debtToAssetRatio: finance?.debtToAssetRatio,
              isLoading: isLoading,
            ),

            const SizedBox(height: 24),

            FinanceSummaryGrid(finance: finance, isLoading: isLoading),

            if (isLoading || (finance?.topMovers.isNotEmpty ?? false)) ...[
              const SizedBox(height: 32),
              TopMoversListSection(
                movers: finance?.topMovers ?? [],
                isLoading: isLoading,
              ),
            ],

            AccountTypeListSection(
              accountTypes: finance?.accountTypes ?? [],
              isLoading: isLoading,
            ),

            const SizedBox(height: 32),

            AccountListSection(
              accounts: finance?.accounts ?? [],
              isLoading: isLoading,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
