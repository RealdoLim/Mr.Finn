import 'package:drift/drift.dart';

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get description => text()();

  RealColumn get amount => real()();

  DateTimeColumn get date => dateTime()();

  TextColumn get direction => text()();
  // expected values: income / expense

  TextColumn get source => text()();
  // expected values: manual / bank_notification

  TextColumn get transactionKind =>
    text().withDefault(const Constant('normal_income'))();
  // values:
  // normal_income
  // normal_expense
  // debt_given_outflow
  // debt_given_repayment
  // debt_owed_repayment

  TextColumn get category => text().nullable()();
  // nullable because income does not need category

  TextColumn get spendingType => text().nullable()();
  // nullable because income does not need spending type

  IntColumn get linkedDebtId => integer().nullable()();
  // nullable because not every transaction is debt-related

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}