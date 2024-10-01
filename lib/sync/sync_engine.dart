import 'package:drift/drift.dart';

import '../core/api/api_client.dart';
import '../core/api/api_exception.dart';
import '../data/database.dart';
import 'transaction_json.dart';

/// Outcome of one sync run, for the status UI and logs.
class SyncResult {
  SyncResult();

  int pushed = 0;
  int conflicts = 0;
  int failed = 0;

  /// True when the run stopped early because the server was unreachable.
  bool offline = false;
}

/// Moves local changes to the server and server changes to the device,
/// following the protocol in finance-tracker's ADR 3.
class SyncEngine {
  SyncEngine(this._db, this._api);

  final AppDatabase _db;
  final ApiClient _api;

  /// Sends queued changes oldest first. Stops at the first network failure
  /// (everything stays queued); a rejected change is recorded and skipped,
  /// along with later changes to the same transaction.
  Future<SyncResult> push() async {
    final result = SyncResult();
    final blocked = <String>{};
    final entries = await (_db.select(_db.outbox)
          ..orderBy([(o) => OrderingTerm.asc(o.id)]))
        .get();

    for (final entry in entries) {
      if (blocked.contains(entry.clientId)) continue;
      try {
        final conflicted = await _push(entry);
        if (conflicted) result.conflicts++;
        await (_db.delete(_db.outbox)..where((o) => o.id.equals(entry.id)))
            .go();
        result.pushed++;
      } on NetworkException catch (e) {
        await _recordFailure(entry, e);
        return result..offline = true;
      } on RateLimitedException catch (e) {
        await _recordFailure(entry, e);
        return result..offline = true;
      } on ServerException catch (e) {
        await _recordFailure(entry, e);
        return result..offline = true;
      } on ApiException catch (e) {
        await _recordFailure(entry, e);
        blocked.add(entry.clientId);
        result.failed++;
      }
    }
    return result;
  }

  /// Returns true when the server rejected an update as conflicting and its
  /// copy replaced ours.
  Future<bool> _push(OutboxData entry) async {
    switch (entry.operation) {
      case 'create':
        final row = await _row(entry.clientId);
        if (row == null || row.serverId != null) return false;
        final json = await _api.post(
          '/transactions',
          {'transaction': TransactionJson.toRequest(row)},
        );
        await _saveServerState(row.clientId, json);
        return false;

      case 'update':
        final row = await _row(entry.clientId);
        if (row == null || row.serverId == null) return false;
        try {
          final json = await _api.patch('/transactions/${row.serverId}', {
            if (row.serverUpdatedAt != null)
              'if_unmodified_since':
                  row.serverUpdatedAt!.toUtc().toIso8601String(),
            'transaction': TransactionJson.toRequest(row),
          });
          await _saveServerState(row.clientId, json);
          return false;
        } on ConflictException catch (e) {
          if (e.serverCopy != null) await _applyServerCopy(row, e.serverCopy!);
          return true;
        }

      case 'delete':
        if (entry.serverId == null) return false;
        try {
          await _api.delete('/transactions/${entry.serverId}');
        } on NotFoundException {
          // Already gone on the server.
        }
        return false;

      default:
        throw StateError('Unknown outbox operation ${entry.operation}');
    }
  }

  Future<Transaction?> _row(String clientId) =>
      (_db.select(_db.transactions)..where((t) => t.clientId.equals(clientId)))
          .getSingleOrNull();

  Future<void> _saveServerState(String clientId, Map<String, dynamic> json) =>
      (_db.update(_db.transactions)..where((t) => t.clientId.equals(clientId)))
          .write(
        TransactionsCompanion(
          serverId: Value(json['id'] as int),
          serverUpdatedAt: Value(DateTime.parse(json['updated_at'] as String)),
        ),
      );

  Future<void> _applyServerCopy(Transaction row, Map<String, dynamic> json) =>
      (_db.update(_db.transactions)
            ..where((t) => t.localId.equals(row.localId)))
          .write(
        TransactionJson.fromServer(json)
            .copyWith(clientId: Value(row.clientId)),
      );

  Future<void> _recordFailure(OutboxData entry, ApiException e) =>
      (_db.update(_db.outbox)..where((o) => o.id.equals(entry.id))).write(
        OutboxCompanion(
          attempts: Value(entry.attempts + 1),
          lastError: Value(e.message),
        ),
      );
}
