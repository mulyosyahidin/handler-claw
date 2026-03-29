import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/whatsapp-logs/application/whatsapp_logs_controller.dart';
import 'package:handlerclaw/features/whatsapp-logs/presentation/widgets/chat_bubble.dart';
import 'package:handlerclaw/shared/widgets/error_full_page.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';

class WhatsAppLogsPage extends ConsumerStatefulWidget {
  const WhatsAppLogsPage({super.key});

  @override
  ConsumerState<WhatsAppLogsPage> createState() => _WhatsAppLogsPageState();
}

class _WhatsAppLogsPageState extends ConsumerState<WhatsAppLogsPage> {
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
      ref.read(whatsappLogListControllerProvider.notifier).loadMore();
    }
  }

  Future<void> _refresh() async {
    await ref.read(whatsappLogListControllerProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(whatsappLogListControllerProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('WhatsApp Logs', style: AppTextStyles.title()),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => ref
                  .read(whatsappLogListControllerProvider.notifier)
                  .onSearchChanged(val),
              decoration: InputDecoration(
                hintText: 'Cari nama, nomor, atau pesan...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(whatsappLogListControllerProvider.notifier)
                              .onSearchChanged('');
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
 
          // Filters
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Semua',
                    isSelected: state.value?.isGroup == null,
                    onSelected: (selected) {
                      if (selected) {
                        ref
                            .read(whatsappLogListControllerProvider.notifier)
                            .onFilterChanged(null);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Personal',
                    isSelected: state.value?.isGroup == false,
                    onSelected: (selected) {
                      if (selected) {
                        ref
                            .read(whatsappLogListControllerProvider.notifier)
                            .onFilterChanged(false);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Grup',
                    isSelected: state.value?.isGroup == true,
                    onSelected: (selected) {
                      if (selected) {
                        ref
                            .read(whatsappLogListControllerProvider.notifier)
                            .onFilterChanged(true);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          // List
          Expanded(
            child: state.when(
              data: (logsState) {
                if (logsState.items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          logsState.search?.isNotEmpty == true
                              ? 'Tidak hasil ditemukan untuk "${logsState.search}"'
                              : 'Tidak ada logs WhatsApp',
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
                      vertical: 0,
                    ),
                    itemCount:
                        logsState.items.length +
                        (logsState.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == logsState.items.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final log = logsState.items[index];

                      return ChatBubble(log: log);
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
 
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;
 
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });
 
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
 
    return FilterChip(
      label: Text(
        label,
        style: AppTextStyles.label(
          color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: colorScheme.primary,
      checkmarkColor: colorScheme.onPrimary,
      backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
    );
  }
}
