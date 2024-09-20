import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../data/reference_repository.dart';
import 'api/api_client.dart';
import 'auth/token_store.dart';

/// Server address, set at build time:
/// `flutter run --dart-define=API_BASE_URL=https://finance.example.com`
const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000',
);

final tokenStoreProvider = Provider<TokenStore>((ref) => SecureTokenStore());

final apiClientProvider = Provider<ApiClient>((ref) {
  final tokens = ref.watch(tokenStoreProvider);
  return ApiClient(baseUrl: apiBaseUrl, tokenProvider: tokens.read);
});

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final referenceRepositoryProvider = Provider<ReferenceRepository>(
  (ref) => ReferenceRepository(
    ref.watch(databaseProvider),
    ref.watch(apiClientProvider),
  ),
);
