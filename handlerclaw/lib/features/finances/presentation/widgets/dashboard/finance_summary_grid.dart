import 'package:flutter/material.dart';
import 'package:handlerclaw/core/utils/currency_utils.dart';
import 'package:handlerclaw/features/finances/domain/entities/finance_overview_entity.dart';
import 'package:handlerclaw/features/home/presentation/widgets/summary_card.dart';

class FinanceSummaryGrid extends StatelessWidget {
  final FinanceOverviewEntity? finance;
  final bool isLoading;

  const FinanceSummaryGrid({
    super.key,
    this.finance,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final crossAxisCount = screenWidth < 380 ? 2 : 3;
        final childAspectRatio = screenWidth < 380 ? 1.3 : 0.7;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: childAspectRatio,
          children: [
            SummaryCard(
              title: 'Liquid',
              value:
                  finance != null
                      ? CurrencyUtils.formatCompact(finance!.liquidAmount)
                      : '',
              icon: Icons.account_balance_wallet_rounded,
              color: Colors.blue,
              percentage:
                  finance != null
                      ? '${finance!.liquidPct.toStringAsFixed(0)}%'
                      : null,
              isLoading: isLoading,
            ),
            SummaryCard(
              title: 'Debt',
              value:
                  finance != null
                      ? CurrencyUtils.formatCompact(finance!.debtAmount)
                      : '',
              icon: Icons.credit_card_rounded,
              color: Colors.red,
              percentage:
                  finance != null
                      ? '${finance!.debtPct.toStringAsFixed(0)}%'
                      : null,
              isLoading: isLoading,
            ),
            SummaryCard(
              title: 'Invest',
              value:
                  finance != null
                      ? CurrencyUtils.formatCompact(finance!.investmentAmount)
                      : '',
              icon: Icons.trending_up_rounded,
              color: Colors.green,
              percentage:
                  finance != null
                      ? '${finance!.investmentPct.toStringAsFixed(0)}%'
                      : null,
              isLoading: isLoading,
            ),
          ],
        );
      },
    );
  }
}
