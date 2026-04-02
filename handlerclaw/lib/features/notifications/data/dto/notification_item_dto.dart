class NotificationItemDto {
  final String type;
  final String title;
  final String linkTo;
  final String message;
  final String eventId;
  final Map<String, dynamic> meta;

  NotificationItemDto({
    required this.type,
    required this.title,
    required this.linkTo,
    required this.message,
    required this.eventId,
    required this.meta,
  });

  factory NotificationItemDto.fromJson(Map<String, dynamic> json) {
    return NotificationItemDto(
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      linkTo: json['link_to'] ?? '',
      message: json['message'] ?? '',
      eventId: json['event_id'] ?? '',
      meta: json['meta'] is Map ? Map<String, dynamic>.from(json['meta']) : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'link_to': linkTo,
      'message': message,
      'event_id': eventId,
      'meta': meta,
    };
  }
}
