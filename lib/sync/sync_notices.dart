import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sync_controller.dart';

/// Tells the user when a sync run replaced their edits with newer ones from
/// the web (the server wins conflicts — see ADR 3 in the API repo).
class SyncNotices extends ConsumerWidget {
  const SyncNotices({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(syncControllerProvider, (previous, next) {
      if (next.conflicts == 0 || next.phase != SyncPhase.idle) return;
      final count = next.conflicts;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 6),
          content: Text(
            count == 1
                ? 'A transaction was edited on the web too, so your change '
                    'was replaced with the newer version.'
                : '$count transactions were edited on the web too, so your '
                    'changes were replaced with the newer versions.',
          ),
        ),
      );
    });
    return child;
  }
}
