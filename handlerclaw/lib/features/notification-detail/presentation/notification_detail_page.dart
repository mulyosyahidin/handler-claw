import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:handlerclaw/app/routes.dart';
import 'package:handlerclaw/core/data/dto/notification_dto.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationDetailPage extends StatelessWidget {
  final NotificationDto data;

  const NotificationDetailPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Detail Notifikasi',
          style: theme.textTheme.titleMedium?.copyWith(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon notifikasi
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_active,
                  color: colorScheme.primary,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Judul notifikasi
            Text(
              data.title ?? 'Notifikasi',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontFamily: 'Georgia',
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurface,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Timestamp
            if (data.triggeredAt != null)
              Center(
                child: Text(
                  _formatTimestamp(data.triggeredAt!),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            const SizedBox(height: 32),

            // Card konten
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PESAN',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      letterSpacing: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data.body ?? 'Tidak ada pesan',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Detail info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INFORMASI',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      letterSpacing: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(
                    label: 'Event ID',
                    value: data.eventId ?? '-',
                    onSurface: colorScheme.onSurface,
                    onSurfaceVariant: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'Tipe',
                    value: data.type ?? '-',
                    onSurface: colorScheme.onSurface,
                    onSurfaceVariant: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'Link',
                    value: data.linkTo ?? '-',
                    onSurface: colorScheme.onSurface,
                    onSurfaceVariant: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Tombol buka link (hanya muncul jika linkTo tidak null)
            if (data.linkTo != null) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final uri = Uri.tryParse(data.linkTo!);
                    if (uri != null && await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text('Buka Link'),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Tombol kembali
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go(Routes.home),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                  elevation: 0,
                ),
                child: const Text('Kembali ke Beranda'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoString;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color onSurface;
  final Color onSurfaceVariant;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.onSurface,
    required this.onSurfaceVariant,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: onSurfaceVariant),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
