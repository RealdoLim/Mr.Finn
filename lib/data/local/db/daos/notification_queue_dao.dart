part of '../app_database.dart';

@DriftAccessor(tables: [NotificationQueue])
class NotificationQueueDao extends DatabaseAccessor<AppDatabase>
    with _$NotificationQueueDaoMixin {
  NotificationQueueDao(super.db);

  Stream<List<NotificationQueueData>> watchAllQueueItems() {
    return (select(notificationQueue)
          ..orderBy([
            (q) => OrderingTerm(
                  expression: q.receivedAt,
                  mode: OrderingMode.desc,
                ),
          ]))
        .watch();
  }

  Future<List<NotificationQueueData>> getAllQueueItems() {
    return select(notificationQueue).get();
  }

  Future<int> insertQueueItem({
    required String rawText,
    String? sourceOrDestination,
    double? detectedAmount,
    String? detectedDirection,
    DateTime? detectedTime,
    String detectionStatus = 'parsed',
  }) {
    return into(notificationQueue).insert(
      NotificationQueueCompanion.insert(
        rawText: rawText,
        sourceOrDestination: Value(sourceOrDestination),
        detectedAmount: Value(detectedAmount),
        detectedDirection: Value(detectedDirection),
        detectedTime: Value(detectedTime),
        detectionStatus: Value(detectionStatus),
      ),
    );
  }

  Future<int> deleteQueueItem(int id) {
    return (delete(notificationQueue)..where((q) => q.id.equals(id))).go();
  }
}