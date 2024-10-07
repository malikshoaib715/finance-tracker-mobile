import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dates.dart';
import '../../core/providers.dart';
import '../../data/database.dart';
import '../../sync/sync_controller.dart';

/// First day of the month being viewed.
final selectedMonthProvider = StateProvider.autoDispose<DateTime>((ref) {
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

final monthTransactionsProvider =
    StreamProvider.autoDispose<List<DayGroup>>((ref) {
  final month = ref.watch(selectedMonthProvider);
  return ref
      .watch(transactionsRepositoryProvider)
      .watchMonth(month)
      .map(groupByDay);
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
