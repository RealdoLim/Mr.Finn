import 'package:drift/drift.dart';

class Debts extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get personName => text()();

  RealColumn get originalAmount => real()();

  RealColumn get remainingBalance => real()();

  TextColumn get description => text()();

  DateTimeColumn get dateCreated => dateTime()();

  TextColumn get type => text()();
  // expected values: owed / given

  TextColumn get status => text()();
  // expected values: active / partially_paid / settled

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}