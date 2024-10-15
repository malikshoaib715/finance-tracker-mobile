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

/// What the list shows: search results from any month while searching,
/// otherwise the selected month.
final monthTransactionsProvider =
    StreamProvider.autoDispose.family<List<DayGroup>, int?>((ref, accountId) {
  final repo = ref.watch(transactionsRepositoryProvider);
  final query = ref.watch(searchQueryProvider(accountId)).trim();
  if (query.isNotEmpty) {
    return repo.watchSearch(query, accountId: accountId).map(groupByDay);
  }
  final month = ref.watch(selectedMonthProvider(accountId));
  return repo.watchMonth(month, accountId: accountId).map(groupByDay);
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
