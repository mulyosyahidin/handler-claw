import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/notification/fcm_message_handler.dart';

final fcmMessageHandlerProvider = Provider<FcmMessageHandler>((ref) {
  return FcmMessageHandler(ref);
});