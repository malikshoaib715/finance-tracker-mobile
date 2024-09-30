import 'package:drift/drift.dart';

import '../data/database.dart';

/// Converts between the API's transaction JSON and local rows.
abstract final class TransactionJson {
  /// Request body for POST/PATCH. `client_id` makes creates idempotent.
  static Map<String, dynamic> toRequest(Transaction t) => {
        'client_id': t.clientId,
        'account_id': t.accountId,
        'category_id': t.categoryId,
        'kind': t.kind,
        'amount_cents': t.amountCents,
        'occurred_on': _date(t.occurredOn),
        'description': t.description,
        'notes': t.notes,
        'tag_list': t.tags,
      };

  /// A local row for a transaction as the server returned it.
  static TransactionsCompanion fromServer(Map<String, dynamic> json) =>
      TransactionsCompanion(
        serverId: Value(json['id'] as int),
        clientId: Value(json['client_id'] as String? ?? 'server-${json['id']}'),
        accountId: Value(json['account_id'] as int),
        categoryId: Value(json['category_id'] as int?),
        kind: Value(json['kind'] as String),
        amountCents: Value(json['amount_cents'] as int),
        occurredOn: Value(DateTime.parse(json['occurred_on'] as String)),
        description: Value(json['description'] as String),
        notes: Value(json['notes'] as String?),
        tags: Value(((json['tags'] as List<dynamic>?) ?? const []).join(', ')),
        serverUpdatedAt: Value(DateTime.parse(json['updated_at'] as String)),
      );

  static String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
