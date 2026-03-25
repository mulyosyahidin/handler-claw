import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:handlerclaw/app/app_router.dart';
import 'package:handlerclaw/features/notification-list/data/dto/notification_dto.dart';
import 'package:handlerclaw/features/notification-list/data/notification_api.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationDetailPage extends ConsumerStatefulWidget {
  final String id;
  final NotificationDto? data;

  const NotificationDetailPage({
    super.key,
    required this.id,
    this.data,
  });

  @override
  ConsumerState<NotificationDetailPage> createState() =>
      _NotificationDetailPageState();
}

class _NotificationDetailPageState extends ConsumerState<NotificationDetailPage> {
  late Future<NotificationDto> _fetchFuture;

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      _fetchFuture = Future.value(widget.data!);
    } else {
      _fetchFuture = _fetchData();
    }
  }

  Future<NotificationDto> _fetchData() async {
    final api = ref.read(notificationApiProvider);
    final response = await api.getNotificationDetail(widget.id);
    if (response.data == null) {
      throw Exception('Data not found');
    }
    return response.data!.notification;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FutureBuilder<NotificationDto>(
      future: _fetchFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Notifikasi')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Notifikasi')),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final data = snapshot.data!;
        final payload = data.payloadJson;

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
                fontWeight: FontWeight.w600,
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
                Center(
                  child: Text(
                    payload.title.isNotEmpty ? payload.title : 'Notifikasi',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),

                // Timestamp
                Center(
                  child: Text(
                    _formatTimestamp(data.createdAt),
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
                        payload.message.isNotEmpty ? payload.message : 'Tidak ada pesan',
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
                        value: data.eventId,
                        onSurface: colorScheme.onSurface,
                        onSurfaceVariant: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        label: 'Tipe',
                        value: payload.type.isNotEmpty ? payload.type : '-',
                        onSurface: colorScheme.onSurface,
                        onSurfaceVariant: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        label: 'Status',
                        value: data.status,
                        onSurface: colorScheme.onSurface,
                        onSurfaceVariant: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        label: 'Link',
                        value: payload.linkTo.isNotEmpty ? payload.linkTo : '-',
                        onSurface: colorScheme.onSurface,
                        onSurfaceVariant: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Tombol buka link (hanya muncul jika linkTo tidak kosong)
                if (payload.linkTo.isNotEmpty) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          final uri = Uri.parse(payload.linkTo);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          } else {
                            if (context.mounted) {
                              CherryToast.error(
                                title: const Text(
                                  'Gagal membuka link',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                description: const Text(
                                  'URL tidak valid atau tidak didukung oleh perangkat ini.',
                                ),
                                animationType: AnimationType.fromTop,
                                toastPosition: Position.top,
                              ).show(context);
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            CherryToast.error(
                              title: const Text(
                                'Gagal membuka link',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              description: Text(
                                'Terjadi kesalahan: ${e.toString()}',
                              ),
                              animationType: AnimationType.fromTop,
                              toastPosition: Position.top,
                            ).show(context);
                          }
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
      },
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    try {
      final local = dateTime.toLocal();
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
        'Des'
      ];
      return '${local.day} ${months[local.month - 1]} ${local.year}, ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime.toIso8601String();
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
