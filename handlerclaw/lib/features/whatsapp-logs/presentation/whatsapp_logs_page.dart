import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/models/dto/whatsapp_log_dto.dart';
import 'package:handlerclaw/features/whatsapp-logs/presentation/whatsapp_logs_controller.dart';
import 'package:handlerclaw/shared/presentation/widgets/error_full_page.dart';
import 'package:handlerclaw/shared/themes/app_text_styles.dart';
import 'package:intl/intl.dart';

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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
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
                      return _ChatBubble(log: log);
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

class _ChatBubble extends StatelessWidget {
  final WhatsappLogDto log;

  const _ChatBubble({required this.log});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bubble
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surfaceContainerHighest
                  : colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sender Info
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: log.isGroup
                            ? colorScheme.primaryContainer
                            : colorScheme.secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        log.isGroup
                            ? Icons.group_rounded
                            : Icons.person_rounded,
                        size: 12,
                        color: log.isGroup
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '${log.senderName ?? 'N/A'} - ${log.sender}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Message
                Text(
                  log.messageText ??
                      (log.messageType != 'text'
                          ? '[${log.messageType.toUpperCase()}]'
                          : '(Pesan Kosong)'),
                  style: AppTextStyles.body(
                    fontSize: 15,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                // Time and Date (Bottom)
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    '${DateFormat('dd/MM/yy').format(log.receivedAt.toLocal())} ${DateFormat('HH:mm').format(log.receivedAt.toLocal())}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
