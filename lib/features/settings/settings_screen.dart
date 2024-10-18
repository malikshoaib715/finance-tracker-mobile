import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/providers.dart';
import '../../sync/sync_controller.dart';
import '../auth/auth_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmSignOut(
    BuildContext context,
    WidgetRef ref,
    int pending,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: Text(
          pending == 0
              ? 'You can sign back in at any time.'
              : '$pending change(s) haven’t synced yet and will be lost on '
                  'this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref.read(authControllerProvider.notifier).signOut();
    }
  }

  static String _ago(DateTime? at) {
    if (at == null) return 'Not yet this session';
    final minutes = DateTime.now().difference(at).inMinutes;
    if (minutes < 1) return 'Just now';
    if (minutes < 60) return '$minutes min ago';
    return '${minutes ~/ 60} h ago';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final status = ref.watch(syncControllerProvider);
    final pending = ref.watch(pendingChangesProvider).valueOrNull ?? 0;
    final muted =
        Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (user != null)
            Card(
              child: ListTile(
                leading: CircleAvatar(child: Text(user.name[0])),
                title: Text(user.name),
                subtitle: Text(user.email),
              ),
            ),
          const SizedBox(height: 16),
          Text('Sync', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Last synced'),
                  trailing: Text(_ago(status.lastSyncedAt)),
                ),
                ListTile(
                  title: const Text('Waiting to upload'),
                  trailing: Text('$pending'),
                ),
                if (status.message != null)
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(status.message!, style: muted),
                  ),
                ListTile(
                  leading: const Icon(Icons.sync),
                  title: const Text('Sync now'),
                  enabled: status.phase != SyncPhase.syncing,
                  onTap: () => ref.read(syncControllerProvider.notifier).sync(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                const ListTile(
                  title: Text('Server'),
                  subtitle: Text(apiBaseUrl),
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.expense),
                  title: const Text(
                    'Sign out',
                    style: TextStyle(color: AppColors.expense),
                  ),
                  onTap: () => _confirmSignOut(context, ref, pending),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
