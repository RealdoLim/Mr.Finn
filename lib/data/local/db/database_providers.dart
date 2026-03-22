import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();

  ref.onDispose(() {
    db.close();
  });

  return db;
});

final transactionsDaoProvider = Provider<TransactionsDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.transactionsDao;
});

final debtsDaoProvider = Provider<DebtsDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.debtsDao;
});

final notificationQueueDaoProvider = Provider<NotificationQueueDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.notificationQueueDao;
});