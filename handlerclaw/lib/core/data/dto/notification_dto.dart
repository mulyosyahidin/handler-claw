class NotificationDto {
  final String? title;
  final String? body;
  final String? eventId;
  final String? type;
  final String? linkTo;
  final String? triggeredAt;
  final Map<String, dynamic>? rawData;

  const NotificationDto({
    this.title,
    this.body,
    this.eventId,
    this.type,
    this.linkTo,
    this.triggeredAt,
    this.rawData,
  });

  factory NotificationDto.fromMap(Map<String, dynamic> data) {
    return NotificationDto(
      title: data['title'] as String?,
      body: data['body'] as String?,
      eventId: data['event_id'] as String?,
      type: data['type'] as String?,
      linkTo: data['link_to'] as String?,
      triggeredAt: data['triggered_at'] as String?,
      rawData: data,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'event_id': eventId,
      'type': type,
      'link_to': linkTo,
      'triggered_at': triggeredAt,
      ...?rawData,
    };
  }
}
