import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// Server accounts, cached for offline use. `id` is the server id.
class Accounts extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get kind => text()();
  TextColumn get currency => text().withLength(min: 3, max: 3)();
  IntColumn get position => integer().withDefault(const Constant(0))();
  IntColumn get balanceCents => integer()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Server categories, cached for offline use.
class Categories extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get kind => text()();
  TextColumn get color => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Accounts, Categories])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'finance_tracker'));

  @override
  int get schemaVersion => 1;
}
