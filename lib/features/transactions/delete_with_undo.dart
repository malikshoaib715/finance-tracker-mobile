import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../sync/sync_controller.dart';

/// Deletes a transaction right away and offers Undo in a snackbar. The
/// app-wide messenger is used so the snackbar survives leaving the screen.
Future<void> deleteWithUndo(
  ScaffoldMessengerState messenger,
  WidgetRef ref,
  String clientId,
) async {
  final repo = ref.read(transactionsRepositoryProvider);
  final sync = ref.read(syncControllerProvider.notifier);
  final deleted = await repo.delete(clientId);
  if (deleted == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('Deleted “${deleted.description}”'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => repo.restore(deleted).then((_) => sync.sync()),
        ),
      ),
    );
}
