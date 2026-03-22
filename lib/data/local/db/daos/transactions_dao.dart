part of '../app_database.dart';

@DriftAccessor(tables: [Transactions])
class TransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionsDaoMixin {
  TransactionsDao(super.db);

  Stream<List<Transaction>> watchAllTransactions() {
    return (select(transactions)
          ..orderBy([
            (t) => OrderingTerm(
                  expression: t.date,
                  mode: OrderingMode.desc,
                ),
          ]))
        .watch();
  }

  Future<List<Transaction>> getAllTransactions() {
    return (select(transactions)
          ..orderBy([
            (t) => OrderingTerm(
                  expression: t.date,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
  }

  Future<int> insertTransaction({
    required String description,
    required double amount,
    required DateTime date,
    required String direction,
    required String source,
    required String transactionKind,
    String? category,
    String? spendingType,
    int? linkedDebtId,
  }) {
    return into(transactions).insert(
      TransactionsCompanion.insert(
        description: description,
        amount: amount,
        date: date,
        direction: direction,
        source: source,
        transactionKind: Value(transactionKind),
        category: Value(category),
        spendingType: Value(spendingType),
        linkedDebtId: Value(linkedDebtId),
      ),
    );
  }

  Future<int> deleteTransaction(int id) {
    return (delete(transactions)..where((t) => t.id.equals(id))).go();
  }

  Future<List<Transaction>> getTransactionsForDebt(int debtId) {
    return (select(transactions)
          ..where((t) => t.linkedDebtId.equals(debtId))
          ..orderBy([
            (t) => OrderingTerm(
                  expression: t.date,
                  mode: OrderingMode.asc,
                ),
          ]))
        .get();
  }

  Future<int> deleteTransactionsForDebt(int debtId) {
    return (delete(transactions)..where((t) => t.linkedDebtId.equals(debtId)))
        .go();
  }

  Future<int> updateDebtGivenOutflowTransaction({
    required int debtId,
    required double amount,
    required DateTime date,
    required String description,
  }) {
    return (update(transactions)
          ..where(
            (t) =>
                t.linkedDebtId.equals(debtId) &
                t.transactionKind.equals('debt_given_outflow'),
          ))
        .write(
      TransactionsCompanion(
        description: Value(description),
        amount: Value(amount),
        date: Value(date),
      ),
    );
  }
}