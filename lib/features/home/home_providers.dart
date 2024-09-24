import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final accountsProvider = StreamProvider.autoDispose<List<Account>>(
  (ref) => ref.watch(referenceRepositoryProvider).watchAccounts(),
);
