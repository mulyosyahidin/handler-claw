class WhatsappMessageDto {
  final String id;
  final String webhookLogId;
  final String chatId;
  final String? chatLid;
  final String from;
  final String? fromLid;
  final String? fromName;
  final bool isFromMe;
  final DateTime waTimestamp;
  final String messageType;
  final String? body;
  final String? repliedToId;
  final String? quotedBody;
  final bool isForwarded;
  final String? mediaPath;
  final String? fullMediaPath;
  final String? mediaCaption;
  final String? originalUrl;
  final double? latitude;
  final double? longitude;
  final String? locationThumbnail;
  final String? locationSequence;
  final String? contactName;
  final String? contactVcard;
  final dynamic contacts;
  final String? reaction;
  final String? reactedMessageId;
  final DateTime createdAt;
  final DateTime updatedAt;

  WhatsappMessageDto({
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
    this.fullMediaPath,
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

  factory WhatsappMessageDto.fromJson(Map<String, dynamic> json) {
    return WhatsappMessageDto(
      id: json['id']?.toString() ?? '',
      webhookLogId: json['webhook_log_id']?.toString() ?? '',
      chatId: json['chat_id']?.toString() ?? '',
      chatLid: json['chat_lid']?.toString(),
      from: json['from']?.toString() ?? '',
      fromLid: json['from_lid']?.toString(),
      fromName: json['from_name']?.toString(),
      isFromMe: json['is_from_me'] ?? false,
      waTimestamp: DateTime.parse(
        json['wa_timestamp'] ?? DateTime.now().toIso8601String(),
      ),
      messageType: json['message_type']?.toString() ?? 'text',
      body: json['body']?.toString(),
      repliedToId: json['replied_to_id']?.toString(),
      quotedBody: json['quoted_body']?.toString(),
      isForwarded: json['is_forwarded'] ?? false,
      mediaPath: json['media_path']?.toString(),
      fullMediaPath: json['full_media_path']?.toString(),
      mediaCaption: json['media_caption']?.toString(),
      originalUrl: json['original_url']?.toString(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationThumbnail: json['location_thumbnail']?.toString(),
      locationSequence: json['location_sequence']?.toString(),
      contactName: json['contact_name']?.toString(),
      contactVcard: json['contact_vcard']?.toString(),
      contacts: json['contacts'],
      reaction: json['reaction']?.toString(),
      reactedMessageId: json['reacted_message_id']?.toString(),
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'webhook_log_id': webhookLogId,
      'chat_id': chatId,
      'chat_lid': chatLid,
      'from': from,
      'from_lid': fromLid,
      'from_name': fromName,
      'is_from_me': isFromMe,
      'wa_timestamp': waTimestamp.toIso8601String(),
      'message_type': messageType,
      'body': body,
      'replied_to_id': repliedToId,
      'quoted_body': quotedBody,
      'is_forwarded': isForwarded,
      'media_path': mediaPath,
      'full_media_path': fullMediaPath,
      'media_caption': mediaCaption,
      'original_url': originalUrl,
      'latitude': latitude,
      'longitude': longitude,
      'location_thumbnail': locationThumbnail,
      'location_sequence': locationSequence,
      'contact_name': contactName,
      'contact_vcard': contactVcard,
      'contacts': contacts,
      'reaction': reaction,
      'reacted_message_id': reactedMessageId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
