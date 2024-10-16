import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dates.dart';
import '../../core/providers.dart';
import '../../data/database.dart';
import '../../sync/sync_controller.dart';

/// First day of the month being viewed, per account (null = all accounts).
final selectedMonthProvider =
    StateProvider.autoDispose.family<DateTime, int?>((ref, _) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

/// One day's transactions, newest day first.
class DayGroup {
  const DayGroup(this.day, this.transactions);
  final DateTime day;
  final List<Transaction> transactions;
}

List<DayGroup> groupByDay(List<Transaction> transactions) {
  final groups = <DateTime, List<Transaction>>{};
  for (final t in transactions) {
    groups.putIfAbsent(Dates.dateOnly(t.occurredOn), () => []).add(t);
  }
  return [for (final e in groups.entries) DayGroup(e.key, e.value)];
}

/// Search text, per account (null = all accounts). Empty = browse by month.
final searchQueryProvider =
    StateProvider.autoDispose.family<String, int?>((ref, _) => '');

/// Narrows the list by type and category; null fields mean "any".
class TransactionFilter {
  const TransactionFilter({this.kind, this.categoryId});
  final String? kind; // expense | income
  final int? categoryId;

  bool get isEmpty => kind == null && categoryId == null;

  bool matches(Transaction t) =>
      (kind == null || t.kind == kind) &&
      (categoryId == null || t.categoryId == categoryId);
}

final filterProvider =
    StateProvider.autoDispose.family<TransactionFilter, int?>(
  (ref, _) => const TransactionFilter(),
);

/// What the list shows: search results from any month while searching,
/// otherwise the selected month.
final monthTransactionsProvider =
    StreamProvider.autoDispose.family<List<DayGroup>, int?>((ref, accountId) {
  final repo = ref.watch(transactionsRepositoryProvider);
  final filter = ref.watch(filterProvider(accountId));
  final query = ref.watch(searchQueryProvider(accountId)).trim();
  final rows = query.isNotEmpty
      ? repo.watchSearch(query, accountId: accountId)
      : repo.watchMonth(
          ref.watch(selectedMonthProvider(accountId)),
          accountId: accountId,
        );
  return rows.map((list) => groupByDay(list.where(filter.matches).toList()));
});

final categoriesByIdProvider = StreamProvider.autoDispose<Map<int, Category>>(
    (ref) => ref
        .watch(referenceRepositoryProvider)
        .watchCategories()
        .map((list) => {for (final c in list) c.id: c}));

/// Account currency by id, so each amount shows in its account's currency.
final accountCurrenciesProvider = StreamProvider.autoDispose<Map<int, String>>(
    (ref) => ref
        .watch(referenceRepositoryProvider)
        .watchAccounts()
        .map((list) => {for (final a in list) a.id: a.currency}));

final accountsListProvider = StreamProvider.autoDispose<List<Account>>(
  (ref) => ref.watch(referenceRepositoryProvider).watchAccounts(),
);

final categoriesListProvider = StreamProvider.autoDispose<List<Category>>(
  (ref) => ref.watch(referenceRepositoryProvider).watchCategories(),
);

/// A single local transaction, for editing.
final transactionProvider =
    FutureProvider.autoDispose.family<Transaction?, String>(
  (ref, clientId) =>
      ref.watch(transactionsRepositoryProvider).findByClientId(clientId),
);
