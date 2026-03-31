import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:handlerclaw/app/app_router.dart';
import 'package:handlerclaw/app/navigation_keys.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';
import 'package:handlerclaw/core/utils/currency_utils.dart';
import 'package:handlerclaw/core/utils/date_utils.dart' as app_date;
import 'package:handlerclaw/core/utils/toast_utils.dart';
import 'package:handlerclaw/core/widgets/shimmer_box.dart';
import 'package:handlerclaw/features/finances/application/account_snapshot_controller.dart';
import 'package:handlerclaw/features/finances/application/accounts_controller.dart';
import 'package:handlerclaw/features/finances/domain/entities/account_entity.dart';
import 'package:handlerclaw/features/finances/domain/entities/account_snapshot_entity.dart';

class AccountSnapshotsPage extends ConsumerStatefulWidget {
  final String accountId;

  const AccountSnapshotsPage({super.key, required this.accountId});

  @override
  ConsumerState<AccountSnapshotsPage> createState() =>
      _AccountSnapshotsPageState();
}

class _AccountSnapshotsPageState extends ConsumerState<AccountSnapshotsPage> {
  // Optimistic removal: langsung hilangkan dari tree saat swipe,
  // sebelum API response kembali — menghindari FlutterError Dismissible.
  final Set<String> _dismissedIds = {};

  @override
  Widget build(BuildContext context) {
    final snapshotsAsync = ref.watch(
      accountSnapshotsProvider(widget.accountId),
    );
    final accountAsync = ref.watch(accountDetailProvider(widget.accountId));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Riwayat Saldo', style: AppTextStyles.label(fontSize: 12)),
            accountAsync.when(
              data: (account) =>
                  Text(account.name, style: AppTextStyles.title(fontSize: 18)),
              loading: () => const ShimmerBox(width: 120, height: 20),
              error: (_, _) =>
                  Text('Akun', style: AppTextStyles.title(fontSize: 18)),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(
          Routes.financeCreateSnapshot,
          extra: {
            'accountId': widget.accountId,
            'accountName': accountAsync.maybeWhen(
              data: (a) => a.name,
              orElse: () => '',
            ),
          },
        ),
        tooltip: 'Tambah Snapshot',
        child: const Icon(Icons.add_rounded),
      ),
      body: (snapshotsAsync.isLoading || accountAsync.isLoading)
          ? _buildBody(context, null, [], isLoading: true)
          : snapshotsAsync.when(
              data: (snapshots) => _buildBody(
                context,
                accountAsync.asData?.value,
                snapshots,
                isLoading: false,
              ),
              loading: () => _buildBody(context, null, [], isLoading: true),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AccountEntity? account,
    List<AccountSnapshotEntity> snapshots, {
    required bool isLoading,
  }) {
    if (isLoading) {
      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: ShimmerBox(
                width: double.infinity,
                height: 160,
                borderRadius: 24,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ShimmerBox(width: double.infinity, height: 80),
                ),
                childCount: 5,
              ),
            ),
          ),
        ],
      );
    }

    // Sort snapshots by date descending
    final visible =
        snapshots.where((s) => !_dismissedIds.contains(s.id)).toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _dismissedIds.clear());
        ref.invalidate(accountSnapshotsProvider(widget.accountId));
        ref.invalidate(accountDetailProvider(widget.accountId));

        await ref.read(accountSnapshotsProvider(widget.accountId).future);
        await ref.read(accountDetailProvider(widget.accountId).future);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── Account Summary Header ──
          if (account != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primaryContainer,
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    account.category,
                                    style: AppTextStyles.label(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  account.name,
                                  style: AppTextStyles.title(fontSize: 20),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => context.push(
                                  Routes.financeEditAccount,
                                  extra: account,
                                ),
                                icon: const Icon(Icons.edit_outlined),
                                iconSize: 20,
                                tooltip: 'Edit Rekening',
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _getCategoryIcon(account.category),
                                size: 32,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(height: 1),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Saldo Saat Ini',
                                  style: AppTextStyles.label(),
                                ),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    CurrencyUtils.formatIdr(
                                      account.currentAmount,
                                    ),
                                    style: AppTextStyles.title(
                                      fontSize: 22,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Snapshots', style: AppTextStyles.label()),
                              Text(
                                '${snapshots.length}',
                                style: AppTextStyles.body(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Snapshots List ──
          if (visible.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada riwayat saldo',
                      style: AppTextStyles.body(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Catatan perubahan saldo akan muncul di sini.',
                      style: AppTextStyles.label(),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final snapshot = visible[index];
                  double? diff;
                  if (index < visible.length - 1) {
                    diff = snapshot.amount - visible[index + 1].amount;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SnapshotTile(
                      key: ValueKey(snapshot.id),
                      snapshot: snapshot,
                      difference: diff,
                      onDismissed: () async {
                        setState(() => _dismissedIds.add(snapshot.id));
                        try {
                          await ref
                              .read(deleteSnapshotControllerProvider.notifier)
                              .deleteSnapshot(
                                id: snapshot.id,
                                accountId: widget.accountId,
                              );
                          
                          // Use root context since this tile is being unmounted
                          final stableContext = rootNavigatorKey.currentContext ?? context;
                          if (stableContext.mounted) {
                            ToastUtils.showSuccess(
                              stableContext,
                              title: 'Berhasil',
                              description: 'Snapshot berhasil dihapus',
                            );
                          }
                        } catch (e) {
                          setState(() => _dismissedIds.remove(snapshot.id));
                          final stableContext = rootNavigatorKey.currentContext ?? context;
                          if (stableContext.mounted) {
                            ToastUtils.showError(
                              stableContext,
                              title: 'Gagal',
                              description: 'Gagal menghapus snapshot',
                            );
                          }
                        }
                      },
                    ),
                  );
                }, childCount: visible.length),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'LIQUID':
        return Icons.account_balance_wallet_rounded;
      case 'INVESTMENT':
        return Icons.trending_up_rounded;
      case 'DEBT':
        return Icons.credit_card_rounded;
      default:
        return Icons.account_balance_rounded;
    }
  }
}

class _SnapshotTile extends StatelessWidget {
  final AccountSnapshotEntity snapshot;
  final double? difference;
  final VoidCallback onDismissed;

  const _SnapshotTile({
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
