import 'dart:convert';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../data/database.dart';
import 'summary.dart';

/// Fetches the month summary, keeping the last good copy for offline use.
class SummaryRepository {
  SummaryRepository(this._db, this._api);

  static const _cacheKey = 'summary';
  final AppDatabase _db;
  final ApiClient _api;

  Future<Summary?> load() async {
    try {
      final json = await _api.get('/summary');
      await _db.into(_db.syncState).insertOnConflictUpdate(
            SyncStateCompanion.insert(key: _cacheKey, value: jsonEncode(json)),
          );
      return Summary.fromJson(json);
    } on NetworkException {
      final cached = await (_db.select(_db.syncState)
            ..where((s) => s.key.equals(_cacheKey)))
          .getSingleOrNull();
      if (cached == null) rethrow;
      return Summary.fromJson(
        jsonDecode(cached.value) as Map<String, dynamic>,
        stale: true,
      );
    }
  }
}
