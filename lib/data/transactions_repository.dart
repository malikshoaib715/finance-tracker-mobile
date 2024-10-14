import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'database.dart';

/// Input for a new or edited transaction, independent of storage.
class TransactionDraft {
  const TransactionDraft({
    required this.accountId,
    required this.kind,
    required this.amountCents,
    required this.occurredOn,
    required this.description,
    this.categoryId,
    this.notes,
    this.tags = '',
  });

  final int accountId;
  final int? categoryId;
  final String kind; // expense | income
  final int amountCents; // positive minor units
  final DateTime occurredOn;
  final String description;
  final String? notes;
  final String tags;
}

/// Local-first transactions. Every write goes to SQLite together with an
/// outbox entry in one database transaction, so a change is never saved
/// without also being queued for sync (or vice versa).
class TransactionsRepository {
  TransactionsRepository(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;

  /// Transactions in [month], newest first; only [accountId]'s if given.
  Stream<List<Transaction>> watchMonth(DateTime month, {int? accountId}) {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    return (_db.select(_db.transactions)
          ..where(
            (t) =>
                t.occurredOn.isBiggerOrEqualValue(start) &
                t.occurredOn.isSmallerThanValue(end) &
                (accountId == null
                    ? const Constant(true)
                    : t.accountId.equals(accountId)),
          )
          ..orderBy([
            (t) => OrderingTerm.desc(t.occurredOn),
            (t) => OrderingTerm.desc(t.localId),
          ]))
        .watch();
  }

  Future<Transaction?> findByClientId(String clientId) =>
      (_db.select(_db.transactions)..where((t) => t.clientId.equals(clientId)))
          .getSingleOrNull();

  /// Saves a new transaction locally and queues it for upload. Returns its client id.
  Future<String> create(TransactionDraft draft) {
    final clientId = _uuid.v4();
    return _db.transaction(() async {
      await _db.into(_db.transactions).insert(
            TransactionsCompanion.insert(
              clientId: clientId,
              accountId: draft.accountId,
              categoryId: Value(draft.categoryId),
              kind: draft.kind,
              amountCents: draft.amountCents,
              occurredOn: draft.occurredOn,
              description: draft.description.trim(),
              notes: Value(draft.notes),
              tags: Value(draft.tags),
            ),
          );
      await _enqueue('create', clientId);
      return clientId;
    });
  }

  Future<void> update(String clientId, TransactionDraft draft) {
    return _db.transaction(() async {
      await (_db.update(_db.transactions)
            ..where((t) => t.clientId.equals(clientId)))
          .write(
        TransactionsCompanion(
          accountId: Value(draft.accountId),
          categoryId: Value(draft.categoryId),
          kind: Value(draft.kind),
          amountCents: Value(draft.amountCents),
          occurredOn: Value(draft.occurredOn),
          description: Value(draft.description.trim()),
          notes: Value(draft.notes),
          tags: Value(draft.tags),
        ),
      );
      await _enqueue('update', clientId);
    });
  }

  /// Deletes locally and queues the delete. Returns the removed row so the
  /// caller can offer [restore].
  Future<Transaction?> delete(String clientId) {
    return _db.transaction(() async {
      final row = await findByClientId(clientId);
      await (_db.delete(_db.transactions)
            ..where((t) => t.clientId.equals(clientId)))
          .go();
      await _enqueue('delete', clientId, serverId: row?.serverId);
      return row;
    });
  }

  /// Undoes [delete]. If the delete hasn't been pushed yet it is simply
  /// dropped and the row comes back as it was; if the server already deleted
  /// it, the row comes back as a new transaction to upload.
  Future<void> restore(Transaction row) {
    return _db.transaction(() async {
      final pending = await (_db.delete(_db.outbox)
            ..where(
              (o) =>
                  o.clientId.equals(row.clientId) &
                  o.operation.equals('delete'),
            ))
          .go();
      if (pending > 0) {
        await _db.into(_db.transactions).insert(row);
        return;
      }
      final clientId = _uuid.v4();
      await _db.into(_db.transactions).insert(
            row.toCompanion(false).copyWith(
                  localId: const Value.absent(),
                  clientId: Value(clientId),
                  serverId: const Value(null),
                  serverUpdatedAt: const Value(null),
                ),
          );
      await _enqueue('create', clientId);
    });
  }

  Future<void> _enqueue(String operation, String clientId, {int? serverId}) =>
      _db.into(_db.outbox).insert(
            OutboxCompanion.insert(
              operation: operation,
              clientId: clientId,
              serverId: Value(serverId),
            ),
          );
}
