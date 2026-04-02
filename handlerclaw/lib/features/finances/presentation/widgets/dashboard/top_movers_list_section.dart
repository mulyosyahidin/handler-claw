import 'package:flutter/material.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';
import 'package:handlerclaw/core/utils/currency_utils.dart';
import 'package:handlerclaw/core/widgets/shimmer_box.dart';
import 'package:handlerclaw/features/finances/domain/entities/finance_overview_entity.dart';

class TopMoversListSection extends StatelessWidget {
  final List<FinanceTopMoverEntity> movers;
  final bool isLoading;

  const TopMoversListSection({
    super.key,
    required this.movers,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Top Movers (30 Hari)', style: AppTextStyles.heading()),
        const SizedBox(height: 16),
        if (isLoading && movers.isEmpty)
          ...List.generate(
            3,
            (index) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: ShimmerBox(width: double.infinity, height: 60),
            ),
          )
        else if (movers.isNotEmpty)
          ...movers
              .take(3)
              .map(
                (mover) => _TopMoverItem(
                  name: mover.name,
                  change: CurrencyUtils.formatIdr(mover.amountChange.abs()),
                  percent:
                      '${mover.direction == FinanceTopMoverDirection.up ? '+' : '-'}${mover.percentChange.toStringAsFixed(1)}%',
                  isUp: mover.direction == FinanceTopMoverDirection.up,
                  isLoading: isLoading,
                ),
              )
        else if (!isLoading)
          const Text('Belum ada data pergerakan signifikan.'),
      ],
    );
  }
}

class _TopMoverItem extends StatelessWidget {
  final String name;
  final String change;
  final String percent;
  final bool isUp;
  final bool isLoading;

  const _TopMoverItem({
    required this.name,
    required this.change,
    required this.percent,
    required this.isUp,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isUp ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isLoading
                    ? const ShimmerBox(width: 100, height: 16)
                    : Text(
                        name,
                        style: AppTextStyles.body(fontWeight: FontWeight.bold),
                      ),
                const SizedBox(height: 4),
                isLoading
                    ? const ShimmerBox(width: 40, height: 12)
                    : Text(percent, style: AppTextStyles.label(color: color)),
              ],
            ),
          ),
          isLoading
              ? const ShimmerBox(width: 80, height: 16)
              : Text(
                  (isUp ? '+ ' : '- ') + change,
                  style: AppTextStyles.body(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
        ],
      ),
    );
  }
}
