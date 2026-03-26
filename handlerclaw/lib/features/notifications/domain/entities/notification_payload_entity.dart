class NotificationPayloadEntity {
  final String type;
  final String title;
  final String linkTo;
  final String message;
  final String eventId;
  final Map<String, dynamic> meta;

  NotificationPayloadEntity({
    required this.type,
    required this.title,
    required this.linkTo,
    required this.message,
    required this.eventId,
    required this.meta,
  });
}
