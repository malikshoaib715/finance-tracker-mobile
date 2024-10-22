import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import '../data/database.dart';

/// A queued change with the transaction it belongs to (null once deleted
/// locally).
class PendingChange {
  const PendingChange(this.entry, this.transaction);
  final OutboxData entry;
  final Transaction? transaction;
}

final pendingChangesListProvider =
    StreamProvider.autoDispose<List<PendingChange>>((ref) {
  final db = ref.watch(databaseProvider);
  final query = db.select(db.outbox).join([
    leftOuterJoin(
      db.transactions,
      db.transactions.clientId.equalsExp(db.outbox.clientId),
    ),
  ])
    ..orderBy([OrderingTerm.asc(db.outbox.id)]);
  return query.watch().map(
        (rows) => [
          for (final row in rows)
            PendingChange(
              row.readTable(db.outbox),
              row.readTableOrNull(db.transactions),
            ),
        ],
      );
});
