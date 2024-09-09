import 'package:finance_tracker_mobile/core/auth/token_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('in-memory store round-trips and clears a token', () async {
    final store = InMemoryTokenStore();
    expect(await store.read(), isNull);

    await store.write('ft_abc');
    expect(await store.read(), 'ft_abc');

    await store.clear();
    expect(await store.read(), isNull);
  });
}
