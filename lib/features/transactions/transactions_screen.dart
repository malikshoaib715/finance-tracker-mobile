import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/dates.dart';
import '../../core/money/money.dart';
import '../../core/widgets/state_views.dart';
import '../../data/database.dart';
import '../../sync/sync_controller.dart';
import '../../sync/sync_status_chip.dart';
import 'transactions_providers.dart';

/// The selected month's transactions from the local database, grouped by day.
/// Works offline; sync keeps it up to date in the background.
class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final days = ref.watch(monthTransactionsProvider);
    final categories = ref.watch(categoriesByIdProvider).valueOrNull ?? {};
    final currencies = ref.watch(accountCurrenciesProvider).valueOrNull ?? {};

    void shiftMonth(int delta) =>
        ref.read(selectedMonthProvider.notifier).state =
            DateTime(month.year, month.month + delta);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: const [SyncStatusChip(), SizedBox(width: 8)],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add transaction',
        onPressed: () => context.push(Routes.newTransaction),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Previous month',
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => shiftMonth(-1),
                ),
                Expanded(
                  child: Text(
                    Dates.month(month),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Next month',
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => shiftMonth(1),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(syncControllerProvider.notifier).sync(),
              child: days.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const ErrorView(
                  message: 'Couldn’t read transactions on this device.',
                ),
                data: (days) => days.isEmpty
                    ? ListView(
                        children: const [
                          EmptyView(
                            message: 'No transactions this month.',
                            icon: Icons.receipt_long_outlined,
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: days.length,
                        itemBuilder: (_, i) => _DaySection(
                          group: days[i],
                          categories: categories,
                          currencies: currencies,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  const _DaySection({
    required this.group,
    required this.categories,
    required this.currencies,
  });
  final DayGroup group;
  final Map<int, Category> categories;
  final Map<int, String> currencies;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
            child: Text(
              Dates.day(group.day),
              style: text.labelLarge?.copyWith(color: AppColors.muted),
            ),
          ),
          Card(
            child: Column(
              children: [
                for (final t in group.transactions)
                  _TransactionTile(
                    transaction: t,
                    category: categories[t.categoryId],
                    currency: currencies[t.accountId] ?? 'PKR',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    required this.currency,
    this.category,
  });
  final Transaction transaction;
  final String currency;
  final Category? category;

  @override
  Widget build(BuildContext context) {
    final income = transaction.kind == 'income';
    final amount = income ? transaction.amountCents : -transaction.amountCents;
    return ListTile(
      onTap: () => context.push(Routes.editTransaction(transaction.clientId)),
      title: Text(transaction.description),
      subtitle: Text(category?.name ?? 'Uncategorised'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (transaction.serverId == null)
            const Padding(
              padding: EdgeInsets.only(right: 6),
              child: Tooltip(
                message: 'Not synced yet',
                child: Icon(Icons.cloud_upload_outlined,
                    size: 16, color: AppColors.muted),
              ),
            ),
          Text(
            Money.format(amount, currency, signed: true),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: income ? AppColors.income : null,
            ),
          ),
        ],
      ),
    );
  }
}
