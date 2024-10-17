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
import 'delete_with_undo.dart';
import 'transactions_providers.dart';

/// The selected month's transactions from the local database, grouped by day,
/// for all accounts or just [accountId]. Works offline; sync keeps it up to
/// date in the background.
class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({this.accountId, super.key});
  final int? accountId;

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _search = TextEditingController();
  bool _searching = false;

  int? get accountId => widget.accountId;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _setSearching(bool searching) {
    setState(() => _searching = searching);
    if (!searching) {
      _search.clear();
      ref.read(searchQueryProvider(accountId).notifier).state = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final searching = _searching;
    final filtered = !ref.watch(filterProvider(accountId)).isEmpty;
    final month = ref.watch(selectedMonthProvider(accountId));
    final days = ref.watch(monthTransactionsProvider(accountId));
    final accountName = accountId == null
        ? null
        : ref
            .watch(accountsListProvider)
            .valueOrNull
            ?.where((a) => a.id == accountId)
            .firstOrNull
            ?.name;
    final categories = ref.watch(categoriesByIdProvider).valueOrNull ?? {};
    final currencies = ref.watch(accountCurrenciesProvider).valueOrNull ?? {};

    void shiftMonth(int delta) =>
        ref.read(selectedMonthProvider(accountId).notifier).state =
            DateTime(month.year, month.month + delta);

    return Scaffold(
      appBar: AppBar(
        title: searching
            ? TextField(
                controller: _search,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search description or notes',
                  border: InputBorder.none,
                  filled: false,
                ),
                onChanged: (text) => ref
                    .read(searchQueryProvider(accountId).notifier)
                    .state = text,
              )
            : Text(accountName ?? 'Transactions'),
        actions: [
          if (searching)
            IconButton(
              tooltip: 'Close search',
              icon: const Icon(Icons.close),
              onPressed: () => _setSearching(false),
            )
          else ...[
            IconButton(
              tooltip: 'Search',
              icon: const Icon(Icons.search),
              onPressed: () => _setSearching(true),
            ),
            const SyncStatusChip(),
            const SizedBox(width: 8),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add transaction',
        onPressed: () =>
            context.push(Routes.newTransaction(accountId: accountId)),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          if (!searching)
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
          _FilterBar(accountId: accountId),
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
                        children: [
                          EmptyView(
                            message: searching
                                ? 'Nothing matches your search.'
                                : filtered
                                    ? 'Nothing matches these filters.'
                                    : 'No transactions this month.',
                            icon: searching
                                ? Icons.search_off
                                : Icons.receipt_long_outlined,
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: days.length + 1,
                        itemBuilder: (_, i) => i == 0
                            ? _TotalsRow(
                                totals: totalsByCurrency(days, currencies),
                              )
                            : _DaySection(
                                group: days[i - 1],
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

class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.accountId});
  final int? accountId;

  Future<void> _pickCategory(
    BuildContext context,
    WidgetRef ref,
    TransactionFilter filter,
    List<Category> all,
  ) async {
    final categories =
        all.where((c) => filter.kind == null || c.kind == filter.kind).toList();
    final picked = await showModalBottomSheet<int>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: const Text('Any category'),
              onTap: () => Navigator.pop(context, -1),
            ),
            for (final c in categories)
              ListTile(
                title: Text(c.name),
                selected: c.id == filter.categoryId,
                onTap: () => Navigator.pop(context, c.id),
              ),
          ],
        ),
      ),
    );
    if (picked == null) return;
    ref.read(filterProvider(accountId).notifier).state = TransactionFilter(
      kind: filter.kind,
      categoryId: picked == -1 ? null : picked,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(filterProvider(accountId));
    final categoryList =
        ref.watch(categoriesListProvider).valueOrNull ?? const <Category>[];
    final categories = {for (final c in categoryList) c.id: c};
    void setKind(String? kind) =>
        ref.read(filterProvider(accountId).notifier).state = TransactionFilter(
          kind: kind,
          // A category of the other type would hide everything.
          categoryId:
              kind != null && categories[filter.categoryId]?.kind != kind
                  ? null
                  : filter.categoryId,
        );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final (kind, label) in [
            (null, 'All'),
            ('expense', 'Expenses'),
            ('income', 'Income'),
          ])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(label),
                selected: filter.kind == kind,
                onSelected: (_) => setKind(kind),
              ),
            ),
          FilterChip(
            label: Text(categories[filter.categoryId]?.name ?? 'Category'),
            selected: filter.categoryId != null,
            onSelected: (_) =>
                _pickCategory(context, ref, filter, categoryList),
          ),
        ],
      ),
    );
  }
}

class _TotalsRow extends StatelessWidget {
  const _TotalsRow({required this.totals});
  final Map<String, Totals> totals;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final MapEntry(key: currency, value: t) in totals.entries)
            Row(
              children: [
                Expanded(
                  child: Text(
                    'In ${Money.format(t.income, currency)}',
                    style: style?.copyWith(color: AppColors.income),
                  ),
                ),
                Text(
                  'Out ${Money.format(t.spent, currency)}',
                  style: style?.copyWith(color: AppColors.expense),
                ),
              ],
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

class _TransactionTile extends ConsumerWidget {
  const _TransactionTile({
    required this.transaction,
    required this.currency,
    this.category,
  });
  final Transaction transaction;
  final String currency;
  final Category? category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final income = transaction.kind == 'income';
    final amount = income ? transaction.amountCents : -transaction.amountCents;
    return Dismissible(
      key: ValueKey(transaction.clientId),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.expense,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => deleteWithUndo(
        ScaffoldMessenger.of(context),
        ref,
        transaction.clientId,
      ),
      child: ListTile(
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
      ),
    );
  }
}
