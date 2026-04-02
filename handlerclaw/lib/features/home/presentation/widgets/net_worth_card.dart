import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:handlerclaw/app/app_router.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';
import 'package:handlerclaw/core/utils/currency_utils.dart';
import 'package:handlerclaw/core/widgets/shimmer_box.dart';
import 'package:handlerclaw/features/finances/application/accounts_controller.dart';

class NetWorthCard extends ConsumerWidget {
  const NetWorthCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return accountsAsync.when(
      data: (result) {
        double assets = 0;
        double debt = 0;

        for (final account in result.accounts) {
          if (account.category == 'DEBT') {
            debt += account.currentAmount;
          } else {
            assets += account.currentAmount;
          }
        }

        final netWorth = assets - debt;

        return Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: InkWell(
            onTap: () => context.push(Routes.financeAccounts),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Net Worth',
                        style: AppTextStyles.label(
                          color: colorScheme.onPrimary.withValues(alpha: 0.8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.account_balance_rounded,
                        color: colorScheme.onPrimary.withValues(alpha: 0.5),
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      CurrencyUtils.formatIdr(netWorth),
                      style: AppTextStyles.hero(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _SmallStat(
                            label: 'Assets',
                            value: CurrencyUtils.formatCompactIdr(assets),
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 24,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        Expanded(
                          child: _SmallStat(
                            label: 'Liabilities',
                            value: CurrencyUtils.formatCompactIdr(debt),
                            color: Colors.white.withValues(alpha: 0.8),
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
      },
      loading: () => const Padding(
        padding: EdgeInsets.only(bottom: 32),
        child: ShimmerBox(
          width: double.infinity,
          height: 180,
          borderRadius: 24,
        ),
      ),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}

class _SmallStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SmallStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: 0.6),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
