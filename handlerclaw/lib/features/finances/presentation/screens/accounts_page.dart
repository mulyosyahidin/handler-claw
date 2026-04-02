import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:handlerclaw/app/app_router.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';
import 'package:handlerclaw/core/utils/currency_utils.dart';
import 'package:handlerclaw/core/widgets/shimmer_box.dart';
import 'package:handlerclaw/features/finances/application/accounts_controller.dart';
import 'package:handlerclaw/features/finances/domain/entities/account_entity.dart';
import 'package:handlerclaw/features/finances/presentation/widgets/accounts/account_tile.dart';
import 'package:handlerclaw/features/finances/presentation/widgets/accounts/accounts_summary_card.dart';
import 'package:handlerclaw/features/finances/presentation/widgets/accounts/account_section_header.dart';
import 'package:handlerclaw/features/finances/presentation/widgets/accounts/empty_accounts_placeholder.dart';

class AccountsPage extends ConsumerStatefulWidget {
  const AccountsPage({super.key});

  @override
  ConsumerState<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends ConsumerState<AccountsPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        ref.read(accountSearchQueryProvider.notifier).clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Cari rekening...',
                  border: InputBorder.none,
                ),
                style: AppTextStyles.body(),
                onChanged: (value) {
                  ref.read(accountSearchQueryProvider.notifier).setQuery(value);
                },
              )
            : Text('Daftar Rekening', style: AppTextStyles.title()),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: accountsAsync.when(
        data: (result) =>
            _buildBody(context, result.accounts, isLoading: false),
        loading: () => _buildBody(context, null, isLoading: true),
        error: (err, stack) =>
            Center(child: Text('Error: $err', style: AppTextStyles.body())),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(Routes.financeCreateAccount),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    List<AccountEntity>? accounts, {
    required bool isLoading,
  }) {
    if (isLoading) {
      return ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: 8,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) =>
            const ShimmerBox(width: double.infinity, height: 70),
      );
    }

    final liquid = accounts!.where((a) => a.category == 'LIQUID').toList();
    final investment = accounts
        .where((a) => a.category == 'INVESTMENT')
        .toList();
    final debt = accounts.where((a) => a.category == 'DEBT').toList();

    // Get others
    final others = accounts
        .where(
          (a) =>
              a.category != 'LIQUID' &&
              a.category != 'INVESTMENT' &&
              a.category != 'DEBT',
        )
        .toList();

    final liquidTotal = liquid.fold<double>(
      0,
      (sum, a) => sum + a.currentAmount,
    );
    final investmentTotal = investment.fold<double>(
      0,
      (sum, a) => sum + a.currentAmount,
    );
    final debtTotal = debt.fold<double>(0, (sum, a) => sum + a.currentAmount);
    final othersTotal = others.fold<double>(
      0,
      (sum, a) => sum + a.currentAmount,
    );

    final totalAssets = liquidTotal + investmentTotal + othersTotal;
    final netWorth = totalAssets - debtTotal.abs();

    return RefreshIndicator(
      onRefresh: () => ref.read(accountsControllerProvider.notifier).refresh(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── Summary Card ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: AccountsSummaryCard(
                netWorth: netWorth,
                totalAssets: totalAssets,
                debtTotal: debtTotal,
              ),
            ),
          ),

          // ── Liquid Section ──
          if (liquid.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: AccountSectionHeader(
                title: 'Kas & Bank',
                total: CurrencyUtils.formatIdr(liquidTotal),
              ),
            ),
            _buildAccountList(liquid),
          ],

          // ── Investment Section ──
          if (investment.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: AccountSectionHeader(
                title: 'Investasi',
                total: CurrencyUtils.formatIdr(investmentTotal),
              ),
            ),
            _buildAccountList(investment),
          ],

          // ── Debt Section ──
          if (debt.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: AccountSectionHeader(
                title: 'Hutang & Cicilan',
                total: CurrencyUtils.formatIdr(debtTotal),
              ),
            ),
            _buildAccountList(debt),
          ],

          // ── Others Section ──
          if (others.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: AccountSectionHeader(
                title: 'Lainnya',
                total: CurrencyUtils.formatIdr(othersTotal),
              ),
            ),
            _buildAccountList(others),
          ],

          if (accounts.isEmpty)
            const SliverToBoxAdapter(
              child: EmptyAccountsPlaceholder(),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildAccountList(List<AccountEntity> accounts) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => AccountTile(account: accounts[index]),
          childCount: accounts.length,
        ),
      ),
    );
  }
}
