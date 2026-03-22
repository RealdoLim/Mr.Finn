part of '../app_database.dart';

@DriftAccessor(tables: [Debts])
class DebtsDao extends DatabaseAccessor<AppDatabase> with _$DebtsDaoMixin {
  DebtsDao(super.db);

  Stream<List<Debt>> watchActiveDebts() {
    return (select(debts)
          ..where((d) => d.status.equals('settled').not())
          ..orderBy([
            (d) => OrderingTerm(
                  expression: d.dateCreated,
                  mode: OrderingMode.desc,
                ),
          ]))
        .watch();
  }

  Stream<List<Debt>> watchSettledDebts() {
    return (select(debts)
          ..where((d) => d.status.equals('settled'))
          ..orderBy([
            (d) => OrderingTerm(
                  expression: d.dateCreated,
                  mode: OrderingMode.desc,
                ),
          ]))
        .watch();
  }

  Future<int> insertDebt({
    required String personName,
    required double originalAmount,
    required double remainingBalance,
    required String description,
    required DateTime dateCreated,
    required String type,
    required String status,
  }) {
    return into(debts).insert(
      DebtsCompanion.insert(
        personName: personName,
        originalAmount: originalAmount,
        remainingBalance: remainingBalance,
        description: description,
        dateCreated: dateCreated,
        type: type,
        status: status,
      ),
    );
  }

  Future<int> updateDebt({
    required int id,
    required String personName,
    required double originalAmount,
    required double remainingBalance,
    required String description,
    required DateTime dateCreated,
    required String type,
    required String status,
  }) {
    return (update(debts)..where((d) => d.id.equals(id))).write(
      DebtsCompanion(
        personName: Value(personName),
        originalAmount: Value(originalAmount),
        remainingBalance: Value(remainingBalance),
        description: Value(description),
        dateCreated: Value(dateCreated),
        type: Value(type),
        status: Value(status),
      ),
    );
  }

  Future<Debt?> getDebtById(int id) {
    return (select(debts)..where((d) => d.id.equals(id))).getSingleOrNull();
  }

  Future<int> deleteDebt(int id) {
    return (delete(debts)..where((d) => d.id.equals(id))).go();
  }

  Stream<List<Debt>> watchSelectableDebts(String direction) {
    final debtType = direction == 'income' ? 'given' : 'owed';

    return (select(debts)
          ..where(
            (d) => d.type.equals(debtType) & d.status.equals('settled').not(),
          )
          ..orderBy([
            (d) => OrderingTerm(
                  expression: d.dateCreated,
                  mode: OrderingMode.desc,
                ),
          ]))
        .watch();
  }

  Future<int> updateDebtBalanceAndStatus({
    required int id,
    required double remainingBalance,
    required String status,
  }) {
    return (update(debts)..where((d) => d.id.equals(id))).write(
      DebtsCompanion(
        remainingBalance: Value(remainingBalance),
        status: Value(status),
      ),
    );
  }
}