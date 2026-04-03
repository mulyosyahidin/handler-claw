enum WhatsappMessageType {
  text,
  image,
  video,
  audio,
  document,
  sticker,
  videoNote,
  location,
  liveLocation,
  contact,
  contactsArray,
  reaction,
  unknown;

  static WhatsappMessageType fromString(String? type) {
    switch (type?.toLowerCase()) {
      case 'text':
        return WhatsappMessageType.text;
      case 'image':
        return WhatsappMessageType.image;
      case 'video':
        return WhatsappMessageType.video;
      case 'audio':
        return WhatsappMessageType.audio;
      case 'document':
        return WhatsappMessageType.document;
      case 'sticker':
        return WhatsappMessageType.sticker;
      case 'video_note':
        return WhatsappMessageType.videoNote;
      case 'location':
        return WhatsappMessageType.location;
      case 'live_location':
        return WhatsappMessageType.liveLocation;
      case 'contact':
        return WhatsappMessageType.contact;
      case 'contacts_array':
        return WhatsappMessageType.contactsArray;
      case 'reaction':
        return WhatsappMessageType.reaction;
      default:
        return WhatsappMessageType.unknown;
    }
  }
}

class WhatsappMessageEntity {
  final String id;
  final String webhookLogId;
  final String chatId;
  final String? chatLid;
  final String from;
  final String? fromLid;
  final String? fromName;
  final bool isFromMe;
  final DateTime waTimestamp;
  final WhatsappMessageType messageType;
  final String? body;
  final String? repliedToId;
  final String? quotedBody;
  final bool isForwarded;
  final String? mediaPath;
  final String? fullPathMedia;
  final String? mediaCaption;
  final String? originalUrl;
  final double? latitude;
  final double? longitude;
  final String? locationThumbnail;
  final BigInt? locationSequence;
  final String? contactName;
  final String? contactVcard;
  final dynamic contacts;
  final String? reaction;
  final String? reactedMessageId;
  final DateTime createdAt;
  final DateTime updatedAt;

  WhatsappMessageEntity({
    required this.id,
    required this.webhookLogId,
    required this.chatId,
    this.chatLid,
    required this.from,
    this.fromLid,
    this.fromName,
    required this.isFromMe,
    required this.waTimestamp,
    required this.messageType,
    this.body,
    this.repliedToId,
    this.quotedBody,
    required this.isForwarded,
    this.mediaPath,
    this.fullPathMedia,
    this.mediaCaption,
    this.originalUrl,
    this.latitude,
    this.longitude,
    this.locationThumbnail,
    this.locationSequence,
    this.contactName,
    this.contactVcard,
    this.contacts,
    this.reaction,
    this.reactedMessageId,
    required this.createdAt,
    required this.updatedAt,
  });
}
