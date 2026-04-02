import 'package:flutter/material.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';
import 'package:handlerclaw/core/utils/currency_utils.dart';

class AccountsSummaryCard extends StatelessWidget {
  final double netWorth;
  final double totalAssets;
  final double debtTotal;

  const AccountsSummaryCard({
    super.key,
    required this.netWorth,
    required this.totalAssets,
    required this.debtTotal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
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
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Total Kekayaan Bersih',
            style: AppTextStyles.label(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyUtils.formatIdr(netWorth),
            style: AppTextStyles.title(color: Colors.white, fontSize: 24),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aset',
                      style: AppTextStyles.label(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      CurrencyUtils.formatIdr(totalAssets),
                      style: AppTextStyles.body(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Hutang',
                      style: AppTextStyles.label(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      CurrencyUtils.formatIdr(debtTotal),
                      style: AppTextStyles.body(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
