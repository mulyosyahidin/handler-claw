import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:handlerclaw/features/whatsapp-hooks/domain/entities/whatsapp_message_entity.dart';
import 'package:handlerclaw/features/whatsapp-hooks/presentation/widgets/whatsapp_audio_player_widget.dart';
import 'package:handlerclaw/features/whatsapp-hooks/presentation/widgets/whatsapp_video_player_widget.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsappMessageDetailPage extends StatelessWidget {
  final WhatsappMessageEntity message;

  const WhatsappMessageDetailPage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Image Preview (if image)
            if (message.messageType == WhatsappMessageType.image &&
                message.fullPathMedia != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  message.fullPathMedia!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 300,
                      width: double.infinity,
                      color: colorScheme.surfaceContainer,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 300,
                      width: double.infinity,
                      color: colorScheme.surfaceContainer,
                      child: Center(
                        child: Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: colorScheme.error.withValues(alpha: 0.5),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Sticker Preview (if sticker)
            if (message.messageType == WhatsappMessageType.sticker &&
                message.fullPathMedia != null) ...[
              Center(
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 200,
                    maxHeight: 200,
                  ),
                  child: Image.network(
                    message.fullPathMedia!,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const CircularProgressIndicator();
                    },
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.sticky_note_2_outlined,
                      size: 64,
                      color: colorScheme.outlineVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Audio Player (if audio)
            if (message.messageType == WhatsappMessageType.audio &&
                message.fullPathMedia != null) ...[
              WhatsappAudioPlayerWidget(url: message.fullPathMedia!),
              const SizedBox(height: 32),
            ],

            // Video Player (if video)
            if (message.messageType == WhatsappMessageType.video &&
                message.fullPathMedia != null) ...[
              WhatsappVideoPlayerWidget(url: message.fullPathMedia!),
              const SizedBox(height: 32),
            ],

            // Document View (if document)
            if (message.messageType == WhatsappMessageType.document &&
                message.fullPathMedia != null)
              _buildDocumentSection(context),

            // Location Thumbnail (if location)
            if ((message.messageType == WhatsappMessageType.location ||
                    message.messageType == WhatsappMessageType.liveLocation) &&
                message.locationThumbnail != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  base64Decode(message.locationThumbnail!),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(),
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Contact Info
            if (message.messageType == WhatsappMessageType.contact ||
                message.messageType == WhatsappMessageType.contactsArray)
              _buildContactSection(context),

            // Plain Text Message Body
            if (message.messageType == WhatsappMessageType.text &&
                message.body != null &&
                message.body!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: _buildDetailItem(
                  context,
                  label: 'Isi Pesan',
                  value: message.body!,
                  icon: Icons.chat_bubble_outline_rounded,
                ),
              ),

            // Media Caption (if exists)
            if (message.mediaCaption != null &&
                message.mediaCaption!.isNotEmpty)
              _buildDetailItem(
                context,
                label: 'Caption',
                value: message.mediaCaption!,
                icon: Icons.info_outline_rounded,
              ),

            if (message.latitude != null && message.longitude != null)
              _buildLocationSection(context),

            _buildDetailItem(
              context,
              label: 'Message ID',
              value: message.id,
              icon: Icons.badge_outlined,
            ),
            _buildDetailItem(
              context,
              label: 'Webhook Log ID',
              value: message.webhookLogId,
              icon: Icons.history_edu_outlined,
            ),
            _buildDetailItem(
              context,
              label: 'Pengirim',
              value: message.fromName ?? message.from,
              subtitle: message.fromLid,
              icon: Icons.person_outline_rounded,
            ),
            _buildDetailItem(
              context,
              label: 'Waktu (WhatsApp)',
              value: DateFormat(
                'dd MMM yyyy, HH:mm:ss',
              ).format(message.waTimestamp.toLocal()),
              icon: Icons.access_time_rounded,
            ),
            _buildDetailItem(
              context,
              label: 'Waktu Input (Sistem)',
              value: DateFormat(
                'dd MMM yyyy, HH:mm:ss',
              ).format(message.createdAt.toLocal()),
              icon: Icons.storage_rounded,
            ),
            _buildDetailItem(
              context,
              label: 'Status',
              value: message.isFromMe ? 'Keluar (Me)' : 'Masuk',
              subtitle: message.isForwarded ? 'Diteruskan' : null,
              icon: Icons.swap_horiz_rounded,
            ),
            _buildDetailItem(
              context,
              label: 'Tipe Pesan',
              value: message.messageType.name.toUpperCase(),
              icon: Icons.category_outlined,
            ),
            if (message.chatId != message.from)
              _buildDetailItem(
                context,
                label: 'Chat ID',
                value: message.chatId,
                subtitle: message.chatLid,
                icon: Icons.chat_bubble_outline_rounded,
              ),
            if (message.fullPathMedia != null)
              _buildDetailItem(
                context,
                label: 'Full Media URL',
                value: message.fullPathMedia!,
                icon: Icons.link_rounded,
                isLink: true,
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filename = message.mediaPath?.split('/').last ?? 'Dokumen';

    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            filename,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final url = Uri.parse(message.fullPathMedia!);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Buka Dokumen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    if (message.messageType == WhatsappMessageType.contact) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: _buildSingleContact(
          context,
          message.contactName ?? 'Tanpa Nama',
          message.contactVcard,
        ),
      );
    }

    // contactsArray
    if (message.contacts is List) {
      final list = message.contacts as List;
      return Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          children: list.map((c) {
            final name = c['displayName'] ?? c['contactName'] ?? 'Kontak';
            final vcard = c['vcard'];
            return _buildSingleContact(context, name, vcard);
          }).toList(),
        ),
      );
    }

    return Container();
  }

  Widget _buildSingleContact(BuildContext context, String name, String? vcard) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final phone = vcard != null ? _extractPhoneFromVcard(vcard) : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colorScheme.primary,
            child: Icon(Icons.person, color: colorScheme.onPrimary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (phone != null)
                  Text(
                    phone,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _extractPhoneFromVcard(String vcard) {
    // Look for WAID pattern first as it's cleaner in WhatsApp vCards
    final waidMatch = RegExp(r'waid=([^:]+)').firstMatch(vcard);
    if (waidMatch != null) return '+${waidMatch.group(1)!}';

    // Fallback to generic TEL pattern
    final telMatch = RegExp(r'TEL[^:]*:([^ \n\r]+)').firstMatch(vcard);
    if (telMatch != null) return telMatch.group(1);

    return null;
  }

  Widget _buildLocationSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final lat = message.latitude!;
    final lng = message.longitude!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailItem(
            context,
            label: 'Koordinat',
            value: '$lat, $lng',
            icon: Icons.location_on_outlined,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 52),
            child: ElevatedButton.icon(
              onPressed: () async {
                final url = Uri.parse(
                  'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
                );
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
              icon: const Icon(Icons.map_outlined),
              label: const Text('Buka di Peta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required String label,
    required String value,
    String? subtitle,
    required IconData icon,
    bool isLink = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
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
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.outline,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: isLink
                      ? AppTextStyles.body(
                          color: colorScheme.primary,
                          fontSize: 13,
                        )
                      : AppTextStyles.body(fontSize: 15),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
