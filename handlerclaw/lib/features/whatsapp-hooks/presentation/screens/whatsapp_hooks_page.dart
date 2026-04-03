import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/whatsapp-hooks/application/whatsapp_hooks_controller.dart';
import 'package:handlerclaw/features/whatsapp-hooks/presentation/widgets/whatsapp_message_item_widget.dart';
import 'package:handlerclaw/features/whatsapp-hooks/domain/entities/whatsapp_message_entity.dart';
import 'package:handlerclaw/app/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:handlerclaw/shared/widgets/error_full_page.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';

class WhatsappHooksPage extends ConsumerStatefulWidget {
  const WhatsappHooksPage({super.key});

  @override
  ConsumerState<WhatsappHooksPage> createState() => _WhatsappHooksPageState();
}

class _WhatsappHooksPageState extends ConsumerState<WhatsappHooksPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(whatsappHooksControllerProvider.notifier).loadMore();
    }
  }

  Future<void> _refresh() async {
    await ref.read(whatsappHooksControllerProvider.notifier).refresh();
  }

  void _showMessageDetails(WhatsappMessageEntity message) {
    context.push(Routes.whatsappMessageDetail, extra: message);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(whatsappHooksControllerProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('WhatsApp Messages', style: AppTextStyles.title()),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => ref
                  .read(whatsappHooksControllerProvider.notifier)
                  .setSearch(val),
              decoration: InputDecoration(
                hintText: 'Cari pengirim atau pesan...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(whatsappHooksControllerProvider.notifier)
                              .setSearch(null);
                        },
                      )
                    : null,
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary, width: 1),
                ),
              ),
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Semua'),
                  selected: state.value?.isFromMe == null,
                  onSelected: (selected) {
                    if (selected) {
                      ref
                          .read(whatsappHooksControllerProvider.notifier)
                          .setFilter(clearIsFromMe: true);
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Masuk'),
                  selected: state.value?.isFromMe == false,
                  onSelected: (selected) {
                    if (selected) {
                      ref
                          .read(whatsappHooksControllerProvider.notifier)
                          .setFilter(isFromMe: false);
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Keluar (Me)'),
                  selected: state.value?.isFromMe == true,
                  onSelected: (selected) {
                    if (selected) {
                      ref
                          .read(whatsappHooksControllerProvider.notifier)
                          .setFilter(isFromMe: true);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // List
          Expanded(
            child: state.when(
              data: (hookState) {
                if (hookState.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.message_outlined,
                          size: 64,
                          color: colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          hookState.search?.isNotEmpty == true
                              ? 'Tidak hasil ditemukan untuk "${hookState.search}"'
                              : 'Tidak ada pesan WhatsApp',
                          style: AppTextStyles.body(color: colorScheme.outline),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount:
                        hookState.messages.length +
                        (hookState.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == hookState.messages.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final message = hookState.messages[index];

                      return WhatsappMessageItemWidget(
                        message: message,
                        onTap: () => _showMessageDetails(message),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  ErrorFullPage(message: error.toString(), onRefresh: _refresh),
            ),
          ),
        ],
      ),
    );
  }
}
