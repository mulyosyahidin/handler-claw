import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/devices/domain/entities/user_device_entity.dart';
import 'package:handlerclaw/features/devices/application/devices_controller.dart';
import 'package:handlerclaw/features/devices/presentation/widgets/device_card.dart';
import 'package:handlerclaw/features/devices/presentation/widgets/device_detail_bottom_sheet.dart';
import 'package:handlerclaw/shared/widgets/error_full_page.dart';
import 'package:handlerclaw/core/services/device_info_plus_service.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';

class DevicesPage extends ConsumerStatefulWidget {
  const DevicesPage({super.key});

  @override
  ConsumerState<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends ConsumerState<DevicesPage> {
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
      ref.read(userDevicesControllerProvider.notifier).loadMore();
    }
  }

  Future<void> _refresh() async {
    await ref.read(userDevicesControllerProvider.notifier).refresh();
  }

  void _showDeviceDetail(UserDeviceEntity device) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DeviceDetailBottomSheet(deviceId: device.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userDevicesControllerProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Devices', style: AppTextStyles.title(fontSize: 24)),
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
                  .read(userDevicesControllerProvider.notifier)
                  .onSearchChanged(val),
              decoration: InputDecoration(
                hintText: 'Cari brand, model, atau ID...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(userDevicesControllerProvider.notifier)
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
              data: (devicesState) {
                if (devicesState.items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.device_unknown_rounded,
                          size: 64,
                          color: colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          devicesState.search?.isNotEmpty == true
                              ? 'Tidak hasil ditemukan untuk "${devicesState.search}"'
                              : 'Belum ada perangkat terdaftar',
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount:
                        devicesState.items.length +
                        (devicesState.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == devicesState.items.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final device = devicesState.items[index];
                      final currentDeviceId = ref
                          .watch(currentDeviceIdProvider)
                          .value;
                      return DeviceCard(
                        device: device,
                        isCurrent: device.deviceId == currentDeviceId,
                        onTap: () => _showDeviceDetail(device),
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
