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

  static const _transactionsMark = 'transactions_since';
  static const _deletionsMark = 'deletions_since';

  /// Applies server changes since the last pull. High-water marks come from
  /// server timestamps (not the device clock), and rows with unpushed local
  /// changes are left alone until those changes reach the server.
  Future<int> pull() async {
    final pending =
        (await _db.select(_db.outbox).get()).map((o) => o.clientId).toSet();
    var applied = 0;

    final since = await _mark(_transactionsMark);
    String? cursor;
    String? newest = since;
    do {
      final page = await _api.get('/transactions', query: {
        if (since != null) 'updated_since': since,
        if (cursor != null) 'cursor': cursor,
      });
      final rows =
          (page['transactions'] as List<dynamic>).cast<Map<String, dynamic>>();
      await _db.transaction(() async {
        for (final json in rows) {
          if (await _upsertFromServer(json, pending)) applied++;
          newest = json['updated_at'] as String;
        }
      });
      cursor = page['next_cursor'] as String?;
    } while (cursor != null);
    if (newest != null) await _setMark(_transactionsMark, newest!);

    final deletionsSince = await _mark(_deletionsMark);
    final deletions = ((await _api.get('/deletions', query: {
      if (deletionsSince != null) 'since': deletionsSince,
    }))['deletions'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    await _db.transaction(() async {
      for (final d
          in deletions.where((d) => d['record_type'] == 'Transaction')) {
        await (_db.delete(_db.transactions)
              ..where((t) => t.serverId.equals(d['record_id'] as int)))
            .go();
        applied++;
      }
      if (deletions.isNotEmpty) {
        await _setMark(_deletionsMark, deletions.last['deleted_at'] as String);
      }
    });

    return applied;
  }

  Future<bool> _upsertFromServer(
    Map<String, dynamic> json,
    Set<String> pending,
  ) async {
    final serverId = json['id'] as int;
    final clientId = json['client_id'] as String?;
    final existing = await (_db.select(_db.transactions)
          ..where(
            (t) =>
                t.serverId.equals(serverId) |
                (clientId == null
                    ? const Constant(false)
                    : t.clientId.equals(clientId)),
          ))
        .getSingleOrNull();

    if (existing != null && pending.contains(existing.clientId)) return false;

    final row = TransactionJson.fromServer(json);
    if (existing == null) {
      await _db.into(_db.transactions).insert(row);
    } else {
      await (_db.update(_db.transactions)
            ..where((t) => t.localId.equals(existing.localId)))
          .write(row.copyWith(clientId: Value(existing.clientId)));
    }
    return true;
  }

  Future<String?> _mark(String key) async =>
      (await (_db.select(_db.syncState)..where((s) => s.key.equals(key)))
              .getSingleOrNull())
          ?.value;

  Future<void> _setMark(String key, String value) =>
      _db.into(_db.syncState).insertOnConflictUpdate(
          SyncStateCompanion.insert(key: key, value: value));

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
