import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import 'sync_controller.dart';

/// Stream of "we may be online again" events; overridable in tests.
final connectivityChangesProvider = Provider<Stream<bool>>(
  (ref) => Connectivity()
      .onConnectivityChanged
      .map((results) => !results.contains(ConnectivityResult.none)),
);

/// Starts sync at the right moments for the widget subtree it wraps:
/// on start, on resume, when connectivity returns, and [debounce] after
/// local edits so a burst of edits becomes one run.
class SyncTriggers extends ConsumerStatefulWidget {
  const SyncTriggers({
    required this.child,
    this.debounce = const Duration(seconds: 2),
    super.key,
  });

  final Widget child;
  final Duration debounce;

  @override
  ConsumerState<SyncTriggers> createState() => _SyncTriggersState();
}

class _SyncTriggersState extends ConsumerState<SyncTriggers>
    with WidgetsBindingObserver {
  StreamSubscription<bool>? _connectivity;
  StreamSubscription<void>? _outbox;
  Timer? _debounce;

  void _syncNow() => ref.read(syncControllerProvider.notifier).sync();

  void _syncSoon() {
    _debounce?.cancel();
    _debounce = Timer(widget.debounce, _syncNow);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _connectivity = ref.read(connectivityChangesProvider).listen((online) {
      if (online) _syncNow();
    });
    final db = ref.read(databaseProvider);
    _outbox = db
        .select(db.outbox)
        .watch()
        .where((rows) => rows.isNotEmpty)
        .listen((_) => _syncSoon());
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncNow());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _syncNow();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivity?.cancel();
    _outbox?.cancel();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
