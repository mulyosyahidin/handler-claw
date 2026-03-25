import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:handlerclaw/app/app_router.dart';
import 'package:handlerclaw/core/models/dto/notification_dto.dart';
import 'package:handlerclaw/features/notification-list/presentation/notification_list_controller.dart';
import 'package:handlerclaw/shared/presentation/widgets/error_full_page.dart';
import 'package:handlerclaw/shared/themes/app_text_styles.dart';
import 'package:intl/intl.dart';


class NotificationListPage extends ConsumerStatefulWidget {
  const NotificationListPage({super.key});

  @override
  ConsumerState<NotificationListPage> createState() =>
      _NotificationListPageState();
}

class _NotificationListPageState extends ConsumerState<NotificationListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(notificationListControllerProvider.notifier).loadMore();
    }
  }

  Future<void> _refresh() async {
    await ref.read(notificationListControllerProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationListControllerProvider);



    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifikasi',
          style: AppTextStyles.title(),
        ),

        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      body: notificationState.when(
        data: (state) {
          if (state.items.isEmpty) {
            return const Center(child: Text('Tidak ada notifikasi'));
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == state.items.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final item = state.items[index];
                return _ReminderItemCard(
                  item: item,
                  onTap: () {
                    context.push(
                      Routes.notificationDetail.replaceAll(':id', item.id),
                      extra: item,
                    );
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorFullPage(
          message: error.toString(),
          onRefresh: _refresh,
        ),
      ),
    );
  }
}

class _ReminderItemCard extends StatelessWidget {
  final NotificationDto item;
  final VoidCallback? onTap;

  const _ReminderItemCard({required this.item, this.onTap});

  Color _statusColor(BuildContext context, String status) {
    final cs = Theme.of(context).colorScheme;
    return switch (status.toUpperCase()) {
      'SENT' => Colors.green.shade700,
      'PENDING' => const Color(0xFFB8860B),
      'FAILED' => cs.error,
      _ => cs.onSurfaceVariant,
    };
  }

  Color _statusBg(BuildContext context, String status) {
    return switch (status.toUpperCase()) {
      'SENT' => Colors.green.withValues(alpha: 0.15),
      'PENDING' => const Color(0xFFB8860B).withValues(alpha: 0.15),
      'FAILED' => Theme.of(context).colorScheme.errorContainer,
      _ => Theme.of(context).colorScheme.surfaceContainerHighest,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusBg(context, item.status),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.status,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _statusColor(context, item.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat(
                      'dd MMM yyyy, HH:mm',
                    ).format(item.createdAt.toLocal()),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.payloadJson.title,
                style: AppTextStyles.body(fontWeight: FontWeight.w600, fontSize: 16),
              ),

              const SizedBox(height: 4),
              Text(
                item.payloadJson.message.length > 40
                    ? '${item.payloadJson.message.substring(0, 40)}...'
                    : item.payloadJson.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.event_note, size: 14, color: colorScheme.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item.eventId,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
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
