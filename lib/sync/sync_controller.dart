import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/api_exception.dart';
import '../core/providers.dart';
import '../data/transactions_repository.dart';
import 'sync_engine.dart';

enum SyncPhase { idle, syncing, offline, error }

class SyncStatus {
  const SyncStatus({
    this.phase = SyncPhase.idle,
    this.lastSyncedAt,
    this.pendingChanges = 0,
    this.message,
  });

  final SyncPhase phase;
  final DateTime? lastSyncedAt;
  final int pendingChanges;
  final String? message;

  SyncStatus copyWith({
    SyncPhase? phase,
    DateTime? lastSyncedAt,
    int? pendingChanges,
    String? message,
  }) =>
      SyncStatus(
        phase: phase ?? this.phase,
        lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
        pendingChanges: pendingChanges ?? this.pendingChanges,
        message: message,
      );
}

final syncEngineProvider = Provider<SyncEngine>(
  (ref) =>
      SyncEngine(ref.watch(databaseProvider), ref.watch(apiClientProvider)),
);

final transactionsRepositoryProvider = Provider<TransactionsRepository>(
  (ref) => TransactionsRepository(ref.watch(databaseProvider)),
);

final syncControllerProvider =
    NotifierProvider<SyncController, SyncStatus>(SyncController.new);

/// Runs sync (push, then pull) and exposes its status. Only one run at a time:
/// a request while syncing is coalesced into the running one.
class SyncController extends Notifier<SyncStatus> {
  Future<void>? _running;

  @override
  SyncStatus build() => const SyncStatus();

  Future<void> sync() =>
      _running ??= _run().whenComplete(() => _running = null);

  Future<void> _run() async {
    state = state.copyWith(phase: SyncPhase.syncing);
    final engine = ref.read(syncEngineProvider);
    try {
      final pushed = await engine.push();
      if (pushed.offline) {
        state = state.copyWith(
          phase: SyncPhase.offline,
          pendingChanges: await _pending(),
          message: 'Offline — changes will sync when you’re back online',
        );
        return;
      }
      await engine.pull();
      await ref.read(referenceRepositoryProvider).refresh();
      state = SyncStatus(
        lastSyncedAt: DateTime.now(),
        pendingChanges: await _pending(),
        message: pushed.conflicts > 0
            ? '${pushed.conflicts} change(s) were replaced by newer edits from the web'
            : null,
      );
    } on NetworkException {
      state = state.copyWith(
        phase: SyncPhase.offline,
        pendingChanges: await _pending(),
        message: 'Offline — changes will sync when you’re back online',
      );
    } on ApiException catch (e) {
      state = state.copyWith(phase: SyncPhase.error, message: e.message);
    }
  }

  Future<int> _pending() async {
    final db = ref.read(databaseProvider);
    return (await db.select(db.outbox).get()).length;
  }
}
