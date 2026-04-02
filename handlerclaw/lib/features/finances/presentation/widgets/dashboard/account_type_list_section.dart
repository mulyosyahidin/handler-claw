import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:handlerclaw/app/app_router.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';
import 'package:handlerclaw/core/widgets/shimmer_box.dart';
import 'package:handlerclaw/features/finances/application/account_type_controller.dart';
import 'package:handlerclaw/features/finances/domain/entities/account_type_entity.dart';
import 'package:handlerclaw/features/finances/presentation/widgets/dashboard/empty_section_state.dart';
import 'package:handlerclaw/features/finances/presentation/widgets/shared/finance_widget_helpers.dart';

class AccountTypeListSection extends ConsumerWidget {
  final List<AccountTypeEntity> accountTypes;
  final bool isLoading;

  const AccountTypeListSection({
    super.key,
    required this.accountTypes,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tipe Akun', style: AppTextStyles.heading()),
            TextButton(
              onPressed: () {
                ref.invalidate(accountTypeControllerProvider);
                context.push(Routes.financeAccountTypes);
              },
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: isLoading && accountTypes.isEmpty
              ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) => const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: ShimmerBox(width: 100, height: 100),
                  ),
                )
              : accountTypes.isEmpty
              ? const EmptySectionState(
                  message: 'Belum ada tipe akun',
                  icon: Icons.account_balance_wallet_outlined,
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: accountTypes.length > 3 ? 3 : accountTypes.length,
                  itemBuilder: (context, index) {
                    final type = accountTypes[index];
                    return _TypeItem(
                      name: type.name,
                      count: type.accountCount,
                      icon: FinanceWidgetHelpers.getIconForCategory(
                        type.category,
                      ),
                      color: FinanceWidgetHelpers.getColorForCategory(
                        type.category,
                      ),
                      isLoading: isLoading,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _TypeItem extends StatelessWidget {
  final String name;
  final int count;
  final IconData icon;
  final Color color;
  final bool isLoading;

  const _TypeItem({
    required this.name,
    required this.count,
    required this.icon,
    required this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          isLoading
              ? const ShimmerBox(width: 50, height: 12)
              : Text(
                  name,
                  style: AppTextStyles.body(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
          if (count > 0 || isLoading)
            isLoading
                ? const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: ShimmerBox(width: 30, height: 10),
                  )
                : Text('$count Akun', style: AppTextStyles.label(fontSize: 10)),
        ],
      ),
    );
  }
}
