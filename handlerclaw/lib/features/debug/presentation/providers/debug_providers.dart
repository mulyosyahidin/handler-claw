import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/providers/secure_storage_provider.dart';

final debugStorageDataProvider = FutureProvider<Map<String, String>>((ref) async {
  final storage = ref.watch(secureStorageProvider);
  return await storage.readAll();
});
