import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/devices/domain/entities/user_device_entity.dart';
import 'package:handlerclaw/features/devices/data/repositories/user_device_repository_impl.dart';
import 'package:handlerclaw/core/services/device_info_plus_service.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';
import 'package:intl/intl.dart';

class DeviceDetailBottomSheet extends ConsumerWidget {
  final String deviceId;

  const DeviceDetailBottomSheet({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final repository = ref.watch(userDeviceRepositoryProvider);

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
                child: FutureBuilder<UserDeviceEntity?>(
                  future: repository.getDeviceDetail(deviceId),
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

                    final device = snapshot.data;

                    if (device == null) {
                      return const Center(child: Text('Device not found'));
                    }

                    final userDevice = device;

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

  String _getDeviceDisplayName(UserDeviceEntity device) {
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
