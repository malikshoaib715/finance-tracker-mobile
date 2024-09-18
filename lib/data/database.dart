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

/// Transactions as the device knows them. A row created offline has a
/// [clientId] straight away and gets its [serverId] once the server accepts it.
@TableIndex(name: 'transactions_occurred_on', columns: {#occurredOn})
class Transactions extends Table {
  IntColumn get localId => integer().autoIncrement()();
  IntColumn get serverId => integer().nullable().unique()();
  TextColumn get clientId => text().unique()();
  IntColumn get accountId => integer()();
  IntColumn get categoryId => integer().nullable()();
  TextColumn get kind => text()();
  IntColumn get amountCents => integer()();
  DateTimeColumn get occurredOn => dateTime()();
  TextColumn get description => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get tags => text().withDefault(const Constant(''))();

  /// Server `updated_at` of the last version we saw; sent back on PATCH so
  /// the server can detect conflicting edits.
  DateTimeColumn get serverUpdatedAt => dateTime().nullable()();
}

/// Changes waiting to be pushed, oldest first.
class Outbox extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get operation => text()(); // create | update | delete
  TextColumn get clientId => text()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Small key/value store for sync bookkeeping (high-water marks).
class SyncState extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [Accounts, Categories, Transactions, Outbox, SyncState])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'finance_tracker'));

  @override
  int get schemaVersion => 1;
}
