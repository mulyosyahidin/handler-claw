import 'dart:convert';
import 'package:handlerclaw/features/notifications/data/dto/notification_item_dto.dart';

class NotificationDto {
  final String id;
  final String userId;
  final String eventId;
  final String status;
  final Map<String, dynamic> headersJson;
  final NotificationItemDto payloadJson;
  final String? errorMessage;
  final DateTime? processedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationDto({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.status,
    required this.headersJson,
    required this.payloadJson,
    this.errorMessage,
    this.processedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> headers = {};
    if (json['headers_json'] != null) {
      if (json['headers_json'] is String) {
        try {
          headers = jsonDecode(json['headers_json']);
        } catch (_) {}
      } else if (json['headers_json'] is Map) {
        headers = Map<String, dynamic>.from(json['headers_json']);
      }
    }

    Map<String, dynamic> payloadMap = {};
    if (json['payload_json'] != null) {
      if (json['payload_json'] is String) {
        try {
          payloadMap = jsonDecode(json['payload_json']);
        } catch (_) {}
      } else if (json['payload_json'] is Map) {
        payloadMap = Map<String, dynamic>.from(json['payload_json']);
      }
    }

    return NotificationDto(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      eventId: json['event_id'] ?? '',
      status: json['status'] ?? '',
      headersJson: headers,
      payloadJson: NotificationItemDto.fromJson(payloadMap),
      errorMessage: json['error_message'],
      processedAt: json['processed_at'] != null 
          ? DateTime.parse(json['processed_at']) 
          : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'event_id': eventId,
      'status': status,
      'headers_json': headersJson,
      'payload_json': payloadJson.toJson(),
      'error_message': errorMessage,
      'processed_at': processedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
