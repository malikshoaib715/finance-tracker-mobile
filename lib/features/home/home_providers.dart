import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/providers.dart';
import '../../data/database.dart';
import 'data/summary.dart';
import 'data/summary_repository.dart';

final summaryRepositoryProvider = Provider<SummaryRepository>(
  (ref) => SummaryRepository(
    ref.watch(databaseProvider),
    ref.watch(apiClientProvider),
  ),
);

final summaryProvider = FutureProvider.autoDispose<Summary?>(
  (ref) => ref.watch(summaryRepositoryProvider).load(),
);

/// Local accounts, with a background refresh from the server the first time
/// they're watched (failures are fine: the cached copy keeps showing).
final accountsProvider = StreamProvider.autoDispose<List<Account>>((ref) {
  final repo = ref.watch(referenceRepositoryProvider);
  repo.refresh().catchError((Object e) {
    if (e is! ApiException) throw e;
  });
  return repo.watchAccounts();
});
