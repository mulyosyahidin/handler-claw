class WhatsappLogEntity {
  final String id;
  final String? userId;
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

  WhatsappLogEntity({
    required this.id,
    this.userId,
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
}
