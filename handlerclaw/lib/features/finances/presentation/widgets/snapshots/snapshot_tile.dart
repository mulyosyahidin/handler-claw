import 'package:flutter/material.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';
import 'package:handlerclaw/core/utils/currency_utils.dart';
import 'package:handlerclaw/core/utils/date_utils.dart' as app_date;
import 'package:handlerclaw/features/finances/domain/entities/account_snapshot_entity.dart';

class SnapshotTile extends StatelessWidget {
  final AccountSnapshotEntity snapshot;
  final double? difference;
  final VoidCallback onDismissed;

  const SnapshotTile({
    super.key,
    required this.snapshot,
    required this.onDismissed,
    this.difference,
  });

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Snapshot?'),
        content: Text(
          'Snapshot tanggal ${app_date.DateUtils.formatShort(snapshot.date)} akan dihapus permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPositive = (difference ?? 0) > 0;

    return Dismissible(
      key: ValueKey(snapshot.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => onDismissed(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 24),
      ),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    app_date.DateUtils.formatShort(snapshot.date).split(' ')[0],
                    style: AppTextStyles.body(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  Text(
                    app_date.DateUtils.formatShort(snapshot.date).split(' ')[1],
                    style: AppTextStyles.label(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        CurrencyUtils.formatIdr(snapshot.amount),
                        style: AppTextStyles.body(fontWeight: FontWeight.bold),
                      ),
                      if (difference != null && difference != 0)
                        Row(
                          children: [
                            Icon(
                              isPositive
                                  ? Icons.trending_up_rounded
                                  : Icons.trending_down_rounded,
                              size: 14,
                              color: isPositive ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              (isPositive ? '+' : '') +
                                  CurrencyUtils.formatCompact(difference!),
                              style: AppTextStyles.label(
                                color: isPositive ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  if (snapshot.note != null && snapshot.note!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      snapshot.note!,
                      style: AppTextStyles.label(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
