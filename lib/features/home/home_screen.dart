import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/api/api_exception.dart';
import '../../core/money/money.dart';
import '../../core/providers.dart';
import '../../core/widgets/state_views.dart';
import '../auth/auth_controller.dart';
import 'data/summary.dart';
import 'home_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    try {
      await ref.read(referenceRepositoryProvider).refresh();
    } on ApiException {
      // Accounts stay as cached; the summary shows the offline state.
    }
    ref.invalidate(summaryProvider);
    await ref.read(summaryProvider.future).catchError((_) => null);
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'Changes that haven’t synced yet will be lost on this device.',
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final summary = ref.watch(summaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(user == null ? 'Finance Tracker' : 'Hi, ${user.firstName}'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmSignOut(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            summary.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => ErrorView(
                message: error is ApiException
                    ? error.message
                    : 'Something went wrong loading your summary.',
                onRetry: () => ref.invalidate(summaryProvider),
              ),
              data: (summary) => summary == null
                  ? const SizedBox.shrink()
                  : _SummarySection(summary: summary),
            ),
            const SizedBox(height: 24),
            const _AccountsSection(),
          ],
        ),
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.summary});
  final Summary summary;

  @override
  Widget build(BuildContext context) {
    String money(int cents) => Money.format(cents, summary.currency);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (summary.stale)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: _OfflineBanner(),
          ),
        _StatCard(
          label: 'Net worth',
          value: money(summary.netWorthCents),
          large: true,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Income',
                value: money(summary.incomeCents),
                color: AppColors.income,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Spent',
                value: money(summary.expenseCents),
                color: AppColors.expense,
              ),
            ),
          ],
        ),
        if (summary.budgets.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('Budgets', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                for (final budget in summary.budgets)
                  _BudgetTile(budget: budget, currency: summary.currency),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.color,
    this.large = false,
  });
  final String label;
  final String value;
  final Color? color;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: text.bodySmall?.copyWith(color: AppColors.muted)),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: (large ? text.headlineSmall : text.titleMedium)
                    ?.copyWith(fontWeight: FontWeight.w700, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetTile extends StatelessWidget {
  const _BudgetTile({required this.budget, required this.currency});
  final BudgetProgress budget;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final color = switch (budget.status) {
      'over' => AppColors.expense,
      'warning' => const Color(0xFFF59E0B),
      _ => AppColors.brand,
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(budget.category)),
              Text(
                '${Money.format(budget.spentCents, currency)} of '
                '${Money.format(budget.amountCents, currency)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: budget.ratio.clamp(0, 1),
              minHeight: 6,
              color: color,
              backgroundColor: const Color(0xFFF1F5F9),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountsSection extends ConsumerWidget {
  const _AccountsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsProvider).valueOrNull ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Accounts', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (accounts.isEmpty)
          const Card(
            child: EmptyView(
              message: 'Pull down to load your accounts.',
              icon: Icons.account_balance_wallet_outlined,
            ),
          )
        else
          Card(
            child: Column(
              children: [
                for (final account in accounts)
                  ListTile(
                    title: Text(account.name),
                    subtitle: Text(account.kind.replaceAll('_', ' ')),
                    trailing: Text(
                      Money.format(account.balanceCents, account.currency),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color:
                            account.balanceCents < 0 ? AppColors.expense : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: const Row(
        children: [
          Icon(Icons.cloud_off, size: 18, color: Color(0xFF92400E)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'You’re offline — showing your last synced numbers.',
              style: TextStyle(color: Color(0xFF92400E)),
            ),
          ),
        ],
      ),
    );
  }
}
