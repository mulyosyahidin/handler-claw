import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/models/dto/user_device_dto.dart';
import 'package:handlerclaw/features/devices/data/user_device_api.dart';
import 'package:handlerclaw/features/devices/presentation/devices_controller.dart';
import 'package:handlerclaw/shared/presentation/widgets/error_full_page.dart';
import 'package:handlerclaw/shared/services/device_service.dart';
import 'package:handlerclaw/shared/themes/app_text_styles.dart';
import 'package:intl/intl.dart';

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

  void _showDeviceDetail(UserDeviceDto device) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DeviceDetailBottomSheet(deviceId: device.id),
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
                      return _DeviceCard(
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

class _DeviceCard extends StatelessWidget {
  final UserDeviceDto device;
  final bool isCurrent;
  final VoidCallback onTap;

  const _DeviceCard({
    required this.device,
    required this.onTap,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final statusColor = _getDeviceStatusColor(device.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      color: isDark ? colorScheme.surfaceContainer : Colors.white,
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      _getPlatformIcon(device.platform),
                      color: statusColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getDeviceDisplayName(),
                          style: AppTextStyles.body(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isCurrent ? Colors.green : null,
                          ),
                        ),
                        Text(
                          'ID: ${device.deviceId}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.outline,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isCurrent) ...[
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green,
                      size: 20,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.access_time_rounded,
                label: 'Last Seen',
                value: device.lastSeenAt != null
                    ? DateFormat(
                        'dd MMM yyyy, HH:mm',
                      ).format(device.lastSeenAt!.toLocal())
                    : 'Never',
              ),
              _InfoRow(
                icon: Icons.android_rounded,
                label: 'OS Version',
                value: device.osVersion ?? 'Unknown',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDeviceDisplayName() {
    if (device.deviceBrand != null && device.deviceModel != null) {
      return '${device.deviceBrand} ${device.deviceModel}';
    }
    return device.deviceBrand ?? device.deviceModel ?? 'Unknown Device';
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toUpperCase()) {
      case 'ANDROID':
        return Icons.android_rounded;
      case 'IOS':
        return Icons.phone_iphone_rounded;
      case 'WEB':
        return Icons.language_rounded;
      case 'WINDOWS':
        return Icons.window_rounded;
      default:
        return Icons.device_unknown_rounded;
    }
  }

  Color _getDeviceStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return Colors.green;
      case 'LOGGED_OUT':
        return Colors.orange;
      case 'INVALID_TOKEN':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _DeviceDetailBottomSheet extends ConsumerWidget {
  final String deviceId;

  const _DeviceDetailBottomSheet({required this.deviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final api = ref.watch(userDeviceApiProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder(
                  future: api.getDeviceDetail(deviceId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: AppTextStyles.body(color: Colors.red),
                        ),
                      );
                    }

                    final response = snapshot.data;
                    final device = response?.data;

                    if (device == null) {
                      return const Center(child: Text('Device not found'));
                    }

                    final userDevice = device.userDevice;

                    final currentDeviceId = ref
                        .watch(currentDeviceIdProvider)
                        .value;
                    final isCurrent = userDevice.deviceId == currentDeviceId;

                    final statusColor = _getDeviceStatusColor(
                      userDevice.status,
                    );

                    return ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(24),
                      children: [
                        if (isCurrent) ...[
                          Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.green.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Ini adalah perangkat yang sedang Anda gunakan saat ini.',
                                    style: AppTextStyles.body(
                                      color: Colors.green,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getPlatformIcon(userDevice.platform),
                              size: 48,
                              color: statusColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            _getDeviceDisplayName(userDevice),
                            style: AppTextStyles.title(fontSize: 24),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Center(
                          child: Text(
                            userDevice.status,
                            style: AppTextStyles.body(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        _DetailItem(
                          icon: Icons.fingerprint_rounded,
                          label: 'Device ID',
                          value: userDevice.deviceId,
                          colorScheme: colorScheme,
                        ),
                        _DetailItem(
                          icon: Icons.smartphone_rounded,
                          label: 'Platform',
                          value: userDevice.platform,
                          colorScheme: colorScheme,
                        ),
                        _DetailItem(
                          icon: Icons.info_outline_rounded,
                          label: 'OS Version',
                          value: userDevice.osVersion ?? '-',
                          colorScheme: colorScheme,
                        ),
                        _DetailItem(
                          icon: Icons.access_time_rounded,
                          label: 'Last Seen',
                          value: userDevice.lastSeenAt != null
                              ? DateFormat(
                                  'dd MMM yyyy, HH:mm',
                                ).format(userDevice.lastSeenAt!.toLocal())
                              : 'Never',
                          colorScheme: colorScheme,
                        ),
                        _DetailItem(
                          icon: Icons.calendar_today_rounded,
                          label: 'Registered At',
                          value: DateFormat(
                            'dd MMM yyyy, HH:mm',
                          ).format(userDevice.createdAt.toLocal()),
                          colorScheme: colorScheme,
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        Text(
                          'FCM Token',
                          style: AppTextStyles.body(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            userDevice.fcmToken,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontFamily: 'monospace',
                              color: colorScheme.outline,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getDeviceDisplayName(UserDeviceDto device) {
    if (device.deviceBrand != null && device.deviceModel != null) {
      return '${device.deviceBrand} ${device.deviceModel}';
    }
    return device.deviceBrand ?? device.deviceModel ?? 'Unknown Device';
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toUpperCase()) {
      case 'ANDROID':
        return Icons.android_rounded;
      case 'IOS':
        return Icons.phone_iphone_rounded;
      case 'WEB':
        return Icons.language_rounded;
      case 'WINDOWS':
        return Icons.window_rounded;
      default:
        return Icons.device_unknown_rounded;
    }
  }

  Color _getDeviceStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return Colors.green;
      case 'LOGGED_OUT':
        return Colors.orange;
      case 'INVALID_TOKEN':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme colorScheme;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
                Text(
                  value,
                  style: AppTextStyles.body(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: colorScheme.outline),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.outline,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
