import 'package:flutter/material.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';
import 'package:handlerclaw/core/utils/currency_utils.dart';
import 'package:handlerclaw/core/widgets/shimmer_box.dart';

class NetWorthCard extends StatelessWidget {
  final double? netWorth;
  final double? debtToAssetRatio;
  final bool isLoading;

  const NetWorthCard({
    super.key,
    this.netWorth,
    this.debtToAssetRatio,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Net Worth',
            style: AppTextStyles.label(
              color: colorScheme.onPrimary.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          isLoading || netWorth == null
              ? const ShimmerBox(width: 200, height: 40)
              : Text(
                  CurrencyUtils.formatIdr(netWorth!),
                  style: AppTextStyles.hero(color: colorScheme.onPrimary),
                ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: isLoading || debtToAssetRatio == null
                ? const ShimmerBox(width: 120, height: 14)
                : Text(
                    'Debt-to-Asset: ${(debtToAssetRatio! * 100).toStringAsFixed(1)}%',
                    style: AppTextStyles.label(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
