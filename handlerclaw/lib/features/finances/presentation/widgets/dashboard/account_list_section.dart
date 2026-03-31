import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:handlerclaw/app/app_router.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';
import 'package:handlerclaw/core/widgets/shimmer_box.dart';
import 'package:handlerclaw/features/finances/domain/entities/account_entity.dart';
import 'package:handlerclaw/features/finances/presentation/widgets/accounts/account_tile.dart';
import 'package:handlerclaw/features/finances/presentation/widgets/dashboard/empty_section_state.dart';

class AccountListSection extends StatelessWidget {
  final List<AccountEntity> accounts;
  final bool isLoading;

  const AccountListSection({
    super.key,
    required this.accounts,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Daftar Rekening', style: AppTextStyles.heading()),
            TextButton(
              onPressed: () => context.push(Routes.financeAccounts),
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (isLoading && accounts.isEmpty)
          ...List.generate(
            5,
            (index) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: ShimmerBox(width: double.infinity, height: 70),
            ),
          )
        else if (accounts.isNotEmpty)
          ...[
            ...accounts
                .where(
                  (a) => a.category == 'LIQUID' || a.category == 'INVESTMENT',
                )
                .take(4),
            ...accounts.where((a) => a.category == 'DEBT').take(1),
          ].map((acc) => AccountTile(account: acc))
        else
          const EmptySectionState(
            message: 'Belum ada daftar rekening',
            icon: Icons.account_balance_outlined,
          ),
      ],
    );
  }
}
