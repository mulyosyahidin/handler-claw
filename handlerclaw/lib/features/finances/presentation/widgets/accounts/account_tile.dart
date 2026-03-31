import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:handlerclaw/app/app_router.dart';
import 'package:handlerclaw/app/navigation_keys.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';
import 'package:handlerclaw/core/utils/currency_utils.dart';
import 'package:handlerclaw/core/utils/toast_utils.dart';
import 'package:handlerclaw/features/finances/application/accounts_controller.dart';
import 'package:handlerclaw/features/finances/domain/entities/account_entity.dart';
import 'package:handlerclaw/features/finances/presentation/widgets/shared/finance_widget_helpers.dart';

class AccountTile extends ConsumerWidget {
  final AccountEntity account;

  const AccountTile({super.key, required this.account});

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Rekening?'),
        content: Text(
          'Seluruh riwayat saldo di rekening "${account.name}" akan ikut terhapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (context.mounted) {
        try {
          await ref
              .read(accountsControllerProvider.notifier)
              .deleteAccount(account.id);

          // Use root context since this tile is being unmounted
          final stableContext = rootNavigatorKey.currentContext;
          if (stableContext != null && stableContext.mounted) {
            ToastUtils.showSuccess(
              stableContext,
              title: 'Berhasil',
              description: 'Rekening berhasil dihapus',
            );
          }
        } catch (e) {
          final stableContext = rootNavigatorKey.currentContext;
          if (stableContext != null && stableContext.mounted) {
            ToastUtils.showError(
              stableContext,
              title: 'Gagal',
              description: e.toString().replaceAll('Exception: ', ''),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDebt = account.category == 'DEBT';
    final icon = FinanceWidgetHelpers.getIconForCategory(account.category);
    final color = FinanceWidgetHelpers.getColorForCategory(account.category);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          final path = Routes.financeAccountSnapshots.replaceFirst(
            ':accountId',
            account.id,
          );
          context.push(path);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: AppTextStyles.body(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      CurrencyUtils.formatIdr(account.currentAmount),
                      style: AppTextStyles.label(
                        fontSize: 12,
                        color: isDebt ? Colors.red : null,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onSelected: (value) {
                  if (value == 'edit') {
                    context.push(Routes.financeEditAccount, extra: account);
                  } else if (value == 'delete') {
                    _deleteAccount(context, ref);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 12),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Hapus', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
