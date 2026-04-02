import 'package:flutter_riverpod/flutter_riverpod.dart';

class PendingNotificationNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setNotification(String? id) {
    state = id;
  }
}

final pendingNotificationProvider = 
    NotifierProvider<PendingNotificationNotifier, String?>(PendingNotificationNotifier.new);
