import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:handlerclaw/app/routes.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationData {
  final String? title;
  final String? body;
  final String? eventId;
  final String? type;
  final String? linkTo;
  final String? triggeredAt;
  final Map<String, dynamic>? rawData;

  const NotificationData({
    this.title,
    this.body,
    this.eventId,
    this.type,
    this.linkTo,
    this.triggeredAt,
    this.rawData,
  });

  factory NotificationData.fromMap(Map<String, dynamic> data) {
    return NotificationData(
      title: data['title'] as String?,
      body: data['body'] as String?,
      eventId: data['event_id'] as String?,
      type: data['type'] as String?,
      linkTo: data['link_to'] as String?,
      triggeredAt: data['triggered_at'] as String?,
      rawData: data,
    );
  }
}

class NotificationDetailPage extends StatelessWidget {
  final NotificationData data;

  const NotificationDetailPage({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor =
    isDark ? const Color(0xFF0D0D0F) : const Color(0xFFFAF8F5);
    final Color accentColor =
    isDark ? const Color(0xFFE8C97A) : const Color(0xFFB8860B);
    final Color textPrimary =
    isDark ? const Color(0xFFF5F0E8) : const Color(0xFF1A1814);
    final Color textMuted =
    isDark ? const Color(0xFF6B6660) : const Color(0xFF9A928A);
    final Color cardBg =
    isDark ? const Color(0xFF161412) : const Color(0xFFFFFFFF);
    final Color cardBorder =
    isDark ? const Color(0xFF2A2825) : const Color(0xFFEDE8E1);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Detail Notifikasi',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: textPrimary,
          ),
        ),
        centerTitle: true,
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
                  color: accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_active,
                  color: accentColor,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Judul notifikasi
            Text(
              data.title ?? 'Notifikasi',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 24,
                fontWeight: FontWeight.w400,
                color: textPrimary,
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
                  style: TextStyle(
                    fontSize: 13,
                    color: textMuted,
                  ),
                ),
              ),
            const SizedBox(height: 32),

            // Card konten
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PESAN',
                    style: TextStyle(
                      fontSize: 11,
                      color: textMuted,
                      letterSpacing: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data.body ?? 'Tidak ada pesan',
                    style: TextStyle(
                      fontSize: 15,
                      color: textPrimary,
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
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INFORMASI',
                    style: TextStyle(
                      fontSize: 11,
                      color: textMuted,
                      letterSpacing: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(
                    label: 'Event ID',
                    value: data.eventId ?? '-',
                    textPrimary: textPrimary,
                    textMuted: textMuted,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'Tipe',
                    value: data.type ?? '-',
                    textPrimary: textPrimary,
                    textMuted: textMuted,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'Link',
                    value: data.linkTo ?? '-',
                    textPrimary: textPrimary,
                    textMuted: textMuted,
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
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text(
                    'Buka Link',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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
                  backgroundColor: accentColor.withValues(alpha: 0.12),
                  foregroundColor: accentColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Kembali ke Beranda',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
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
  final Color textPrimary;
  final Color textMuted;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.textPrimary,
    required this.textMuted,
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
            style: TextStyle(
              fontSize: 13,
              color: textMuted,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}