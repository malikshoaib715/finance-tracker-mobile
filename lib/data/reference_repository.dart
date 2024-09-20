import 'package:drift/drift.dart';

import '../core/api/api_client.dart';
import 'database.dart';

/// Accounts and categories: read from the local cache, refreshed from the API.
/// The server owns these (they're edited on the web), so a refresh replaces
/// the cache wholesale inside one transaction.
class ReferenceRepository {
  ReferenceRepository(this._db, this._api);

  final AppDatabase _db;
  final ApiClient _api;

  Stream<List<Account>> watchAccounts() => (_db.select(_db.accounts)
        ..where((a) => a.archived.equals(false))
        ..orderBy([(a) => OrderingTerm.asc(a.position)]))
      .watch();

  Stream<List<Category>> watchCategories() =>
      (_db.select(_db.categories)..orderBy([(c) => OrderingTerm.asc(c.name)]))
          .watch();

  Future<void> refresh() async {
    final accountsBody = await _api.get('/accounts');
    final categoriesBody = await _api.get('/categories');
    final accounts = (accountsBody['accounts'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final categories = (categoriesBody['categories'] as List<dynamic>)
        .cast<Map<String, dynamic>>();

    await _db.transaction(() async {
      await _db.delete(_db.accounts).go();
      await _db.batch(
        (batch) => batch.insertAll(_db.accounts, [
          for (final a in accounts)
            AccountsCompanion.insert(
              id: Value(a['id'] as int),
              name: a['name'] as String,
              kind: a['kind'] as String,
              currency: a['currency'] as String,
              position: Value(a['position'] as int? ?? 0),
              balanceCents: a['balance_cents'] as int,
              archived: Value(a['archived_at'] != null),
            ),
        ]),
      );

      await _db.delete(_db.categories).go();
      await _db.batch(
        (batch) => batch.insertAll(_db.categories, [
          for (final c in categories)
            CategoriesCompanion.insert(
              id: Value(c['id'] as int),
              name: c['name'] as String,
              kind: c['kind'] as String,
              color: c['color'] as String,
            ),
        ]),
      );
    });
  }
}
