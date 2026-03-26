class WhatsappLogDto {
  final int id;
  final DateTime receivedAt;
  final String device;
  final String mode;
  final String sender;
  final String? senderLid;
  final String? senderName;
  final bool isGroup;
  final String? groupId;
  final String? memberPhone;
  final String? memberLid;
  final String? messageText;
  final String messageType;
  final bool isForwarded;
  final bool isQuick;
  final int inboxId;
  final String? extension;
  final String? filename;
  final String? url;
  final String? location;
  final String? pollName;
  final dynamic pollChoices;
  final String waTimestamp;

  WhatsappLogDto({
    required this.id,
    required this.receivedAt,
    required this.device,
    required this.mode,
    required this.sender,
    this.senderLid,
    this.senderName,
    required this.isGroup,
    this.groupId,
    this.memberPhone,
    this.memberLid,
    this.messageText,
    required this.messageType,
    required this.isForwarded,
    required this.isQuick,
    required this.inboxId,
    this.extension,
    this.filename,
    this.url,
    this.location,
    this.pollName,
    this.pollChoices,
    required this.waTimestamp,
  });

  factory WhatsappLogDto.fromJson(Map<String, dynamic> json) {
    return WhatsappLogDto(
      id: json['id'] ?? 0,
      receivedAt: DateTime.parse(json['received_at'] ?? DateTime.now().toIso8601String()),
      device: json['device'] ?? '',
      mode: json['mode'] ?? '',
      sender: json['sender'] ?? '',
      senderLid: json['sender_lid'],
      senderName: json['sender_name'],
      isGroup: json['is_group'] ?? false,
      groupId: json['group_id'],
      memberPhone: json['member_phone'],
      memberLid: json['member_lid'],
      messageText: json['message_text'],
      messageType: json['message_type'] ?? 'text',
      isForwarded: json['is_forwarded'] ?? false,
      isQuick: json['is_quick'] ?? false,
      inboxId: json['inbox_id'] ?? 0,
      extension: json['extension'],
      filename: json['filename'],
      url: json['url'],
      location: json['location'],
      pollName: json['poll_name'],
      pollChoices: json['poll_choices'],
      waTimestamp: json['wa_timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'received_at': receivedAt.toIso8601String(),
      'device': device,
      'mode': mode,
      'sender': sender,
      'sender_lid': senderLid,
      'sender_name': senderName,
      'is_group': isGroup,
      'group_id': groupId,
      'member_phone': memberPhone,
      'member_lid': memberLid,
      'message_text': messageText,
      'message_type': messageType,
      'is_forwarded': isForwarded,
      'is_quick': isQuick,
      'inbox_id': inboxId,
      'extension': extension,
      'filename': filename,
      'url': url,
      'location': location,
      'poll_name': pollName,
      'poll_choices': pollChoices,
      'wa_timestamp': waTimestamp,
    };
  }
}
