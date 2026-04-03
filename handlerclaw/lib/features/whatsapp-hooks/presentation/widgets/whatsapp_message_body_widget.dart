import 'package:flutter/material.dart';
import 'package:handlerclaw/features/whatsapp-hooks/domain/entities/whatsapp_message_entity.dart';

class WhatsappMessageBodyWidget extends StatelessWidget {
  final WhatsappMessageEntity message;
  final TextStyle? style;

  const WhatsappMessageBodyWidget({
    super.key,
    required this.message,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text(_getFormattedText(), style: style);
  }

  String _getFormattedText() {
    final description = _getTypeDescription(message.messageType);

    // If it's a plain text message, just return the body
    if (message.messageType == WhatsappMessageType.text) {
      return message.body ?? '';
    }

    // For media types: if it has a caption, return [Label]\nCaption
    if (message.mediaCaption != null && message.mediaCaption!.isNotEmpty) {
      return '$description\n${message.mediaCaption!}';
    }

    // Fallback: return body if available, otherwise the description (e.g. [Gambar])
    return message.body ?? description;
  }

  String _getTypeDescription(WhatsappMessageType type) {
    switch (type) {
      case WhatsappMessageType.image:
        return '[Gambar]';
      case WhatsappMessageType.video:
        return '[Video]';
      case WhatsappMessageType.audio:
        return '[Audio]';
      case WhatsappMessageType.document:
        return '[Dokumen]';
      case WhatsappMessageType.sticker:
        return '[Stiker]';
      case WhatsappMessageType.location:
        return '[Lokasi]';
      case WhatsappMessageType.liveLocation:
        return '[Lokasi Terkini]';
      case WhatsappMessageType.contact:
      case WhatsappMessageType.contactsArray:
        return '[Kontak]';
      case WhatsappMessageType.reaction:
        return '[Reaksi]';
      default:
        return '';
    }
  }
}
