import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:handlerclaw/app/app_router.dart';
import 'package:handlerclaw/features/notifications/application/notification_list_controller.dart';
import 'package:handlerclaw/features/notifications/presentation/widgets/notification_item_card.dart';
import 'package:handlerclaw/shared/widgets/error_full_page.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';

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
                
                return NotificationItemCard(
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
