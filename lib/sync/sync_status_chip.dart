import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/theme.dart';
import 'sync_controller.dart';

/// Compact sync state for app bars; tap to sync now.
class SyncStatusChip extends ConsumerWidget {
  const SyncStatusChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncControllerProvider);
    final (icon, label, color) = switch (status.phase) {
      SyncPhase.syncing => (Icons.sync, 'Syncing', AppColors.muted),
      SyncPhase.offline => (
          Icons.cloud_off,
          status.pendingChanges > 0
              ? '${status.pendingChanges} waiting'
              : 'Offline',
          const Color(0xFF92400E),
        ),
      SyncPhase.error => (
          Icons.error_outline,
          'Sync failed',
          AppColors.expense
        ),
      SyncPhase.idle => (Icons.cloud_done_outlined, 'Synced', AppColors.brand),
    };
    return Tooltip(
      message: status.message ?? 'Sync now',
      child: ActionChip(
        avatar: Icon(icon, size: 16, color: color),
        label: Text(label),
        labelStyle: TextStyle(color: color, fontSize: 12),
        visualDensity: VisualDensity.compact,
        onPressed: status.phase == SyncPhase.syncing
            ? null
            : () => ref.read(syncControllerProvider.notifier).sync(),
      ),
    );
  }
}
