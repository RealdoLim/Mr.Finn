import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/transactions_table.dart';
import 'tables/debts_table.dart';
import 'tables/notification_queue_table.dart';

part 'daos/transactions_dao.dart';
part 'daos/debts_dao.dart';
part 'daos/notification_queue_dao.dart';
part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Transactions,
    Debts,
    NotificationQueue,
  ],
  daos: [
    TransactionsDao,
    DebtsDao,
    NotificationQueueDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'mr_finn_db'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(transactions, transactions.transactionKind);

            await customStatement('''
              UPDATE transactions
              SET transaction_kind = CASE
                WHEN linked_debt_id IS NULL AND direction = 'income' THEN 'normal_income'
                WHEN linked_debt_id IS NULL AND direction = 'expense' THEN 'normal_expense'
                WHEN linked_debt_id IS NOT NULL AND direction = 'income' THEN 'debt_given_repayment'
                WHEN linked_debt_id IS NOT NULL AND direction = 'expense' THEN 'debt_owed_repayment'
                ELSE 'normal_income'
              END
            ''');
          }
        },
      );
}