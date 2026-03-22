import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/db/app_database.dart';
import '../../../data/local/db/database_providers.dart';
import '../../../data/notification_listener/native_notification_service.dart';

final queueItemsStreamProvider =
    StreamProvider<List<NotificationQueueData>>((ref) {
  final dao = ref.watch(notificationQueueDaoProvider);
  return dao.watchAllQueueItems();
});

final notificationAccessProvider = FutureProvider<bool>((ref) async {
  return NativeNotificationService.isAccessGranted();
});