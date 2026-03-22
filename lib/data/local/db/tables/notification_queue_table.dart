import 'package:drift/drift.dart';

class NotificationQueue extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get rawText => text()();

  TextColumn get sourceOrDestination => text().nullable()();

  RealColumn get detectedAmount => real().nullable()();

  TextColumn get detectedDirection => text().nullable()();
  // expected values: income / expense if detectable

  DateTimeColumn get detectedTime => dateTime().nullable()();

  TextColumn get detectionStatus =>
      text().withDefault(const Constant('pending'))();
  // expected values: pending / parsed / failed

  DateTimeColumn get receivedAt => dateTime().withDefault(currentDateAndTime)();
}