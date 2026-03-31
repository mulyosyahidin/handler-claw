import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:handlerclaw/app/app_router.dart';
import 'package:handlerclaw/app/navigation_keys.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';
import 'package:handlerclaw/core/utils/currency_utils.dart';
import 'package:handlerclaw/core/utils/toast_utils.dart';
import 'package:handlerclaw/features/finances/application/account_type_controller.dart';
import 'package:handlerclaw/features/finances/domain/entities/account_entity.dart';
import 'package:handlerclaw/features/finances/domain/entities/account_type_entity.dart';
import 'package:handlerclaw/features/finances/presentation/widgets/shared/finance_widget_helpers.dart';

class AccountTypeTile extends ConsumerWidget {
  final AccountTypeEntity type;

  const AccountTypeTile({super.key, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final icon = FinanceWidgetHelpers.getIconForCategory(type.category);
    final color = FinanceWidgetHelpers.getColorForCategory(type.category);

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          collapsedShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16,
          ),
          expandedAlignment: Alignment.topLeft,
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          title: Text(
            type.name,
            style: AppTextStyles.body(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            FinanceWidgetHelpers.getCategoryLabel(type.category),
            style: AppTextStyles.label(fontSize: 12),
          ),
          trailing: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyUtils.formatIdr(type.currentTotalAmount),
                style: AppTextStyles.body(fontWeight: FontWeight.bold),
              ),
              Text(
                '${type.accountCount} Akun',
                style: AppTextStyles.label(fontSize: 10),
              ),
            ],
          ),
          children: [
            // Action Buttons
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.push(
                          Routes.financeEditAccountType.replaceFirst(
                            ':id',
                            type.id,
                          ),
                          extra: type,
                        );
                      },
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showDeleteConfirmation(context, ref),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Hapus'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        foregroundColor: colorScheme.error,
                        side: BorderSide(color: colorScheme.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Account List or Empty Message
            ...type.accounts.isEmpty
                ? [
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Belum ada akun untuk tipe ini',
                          textAlign: TextAlign.left,
                          style: AppTextStyles.label(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ]
                : type.accounts.map((acc) {
                    return _AccountSubTile(account: acc);
                  }).toList(),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Tipe Akun'),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${type.name}"? Semua data terkait akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await ref
                    .read(accountTypeControllerProvider.notifier)
                    .deleteAccountType(type.id);

                final activeContext =
                    rootNavigatorKey.currentContext ?? context;
                if (activeContext.mounted) {
                  ToastUtils.showSuccess(
                    activeContext,
                    title: 'Berhasil',
                    description: 'Tipe akun berhasil dihapus',
                  );
                }
              } catch (e) {
                final activeContext =
                    rootNavigatorKey.currentContext ?? context;
                if (activeContext.mounted) {
                  ToastUtils.showError(
                    activeContext,
                    title: 'Gagal',
                    description: e.toString().replaceAll('Exception: ', ''),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _AccountSubTile extends StatelessWidget {
  final AccountEntity account;

  const _AccountSubTile({required this.account});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              account.name,
              style: AppTextStyles.body(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              CurrencyUtils.formatIdr(account.currentAmount),
              style: AppTextStyles.body(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
