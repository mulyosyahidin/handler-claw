import 'package:flutter/material.dart';
import 'package:handlerclaw/features/devices/domain/entities/user_device_entity.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';
import 'package:intl/intl.dart';

class DeviceCard extends StatelessWidget {
  final UserDeviceEntity device;
  final bool isCurrent;
  final VoidCallback onTap;

  const DeviceCard({
    super.key,
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
