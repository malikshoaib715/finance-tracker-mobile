import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/widgets/state_views.dart';
import '../../sync/pending_changes.dart';
import '../../sync/sync_controller.dart';

/// Changes made on this device that the server doesn't have yet, with the
/// reason the last upload attempt failed.
class PendingChangesScreen extends ConsumerWidget {
  const PendingChangesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final changes = ref.watch(pendingChangesListProvider);
    final syncing =
        ref.watch(syncControllerProvider).phase == SyncPhase.syncing;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Waiting to upload'),
        actions: [
          IconButton(
            tooltip: 'Retry now',
            icon: const Icon(Icons.refresh),
            onPressed: syncing
                ? null
                : () => ref.read(syncControllerProvider.notifier).sync(),
          ),
        ],
      ),
      body: changes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            const ErrorView(message: 'Couldn’t read pending changes.'),
        data: (changes) => changes.isEmpty
            ? const EmptyView(
                message: 'Everything is uploaded.',
                icon: Icons.cloud_done_outlined,
              )
            : ListView.separated(
                itemCount: changes.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) => _ChangeTile(change: changes[i]),
              ),
      ),
    );
  }
}

class _ChangeTile extends StatelessWidget {
  const _ChangeTile({required this.change});
  final PendingChange change;

  @override
  Widget build(BuildContext context) {
    final entry = change.entry;
    final (icon, verb) = switch (entry.operation) {
      'create' => (Icons.add_circle_outline, 'New'),
      'update' => (Icons.edit_outlined, 'Edited'),
      _ => (Icons.delete_outline, 'Deleted'),
    };
    final name = change.transaction?.description ?? 'a transaction';
    final error = entry.lastError;
    return ListTile(
      leading: Icon(icon),
      title: Text('$verb: $name'),
      subtitle: error == null
          ? const Text('Not tried yet')
          : Text(
              error,
              style: const TextStyle(color: AppColors.expense),
            ),
      trailing: entry.attempts == 0
          ? null
          : Text(
              entry.attempts == 1 ? '1 try' : '${entry.attempts} tries',
              style: Theme.of(context).textTheme.bodySmall,
            ),
    );
  }
}
