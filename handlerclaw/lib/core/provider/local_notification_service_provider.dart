import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/notification/local_notification_service.dart';

final localNotificationServiceProvider = Provider<LocalNotificationService>((ref) {
  final service = LocalNotificationService();
  service.setRef(ref);
  
  return service;
});