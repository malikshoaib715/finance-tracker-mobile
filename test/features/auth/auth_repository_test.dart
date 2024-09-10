import 'package:finance_tracker_mobile/core/api/api_exception.dart';
import 'package:finance_tracker_mobile/core/auth/token_store.dart';
import 'package:finance_tracker_mobile/features/auth/data/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_api.dart';

const userJson = {
  'id': 1,
  'name': 'Ayesha Khan',
  'email': 'ayesha@example.com',
  'currency': 'PKR',
};

void main() {
  late FakeApi api;
  late InMemoryTokenStore tokens;
  late AuthRepository repo;

  setUp(() {
    api = FakeApi();
    tokens = InMemoryTokenStore();
    repo = AuthRepository(api.client(token: null), tokens);
  });

  test('signing in stores the token and returns the user', () async {
    api.on('POST /session', (201, {'token': 'ft_new', 'user': userJson}));

    final user =
        await repo.signIn(email: ' ayesha@example.com ', password: 'pw');

    expect(user.firstName, 'Ayesha');
    expect(await tokens.read(), 'ft_new');
    expect(
      api.requests.single.data,
      containsPair('email', 'ayesha@example.com'),
    );
  });

  test('wrong credentials surface as UnauthorizedException', () async {
    api.on(
      'POST /session',
      (
        401,
        {
          'error': {'message': 'Invalid email or password'},
        }
      ),
    );
    expect(
      () => repo.signIn(email: 'x@example.com', password: 'nope'),
      throwsA(isA<UnauthorizedException>()),
    );
    expect(await tokens.read(), isNull);
  });

  test('a revoked token signs the user out', () async {
    await tokens.write('ft_old');
    api.on(
      'GET /me',
      (
        401,
        {
          'error': {'message': 'Missing or invalid API token'},
        }
      ),
    );

    expect(await repo.currentUser(), isNull);
    expect(await tokens.read(), isNull);
  });

  test('signing out forgets the token even when offline', () async {
    await tokens.write('ft_old');
    await repo.signOut(); // no route: behaves like a network failure
    expect(await tokens.read(), isNull);
  });
}
