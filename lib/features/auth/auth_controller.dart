import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import 'data/auth_repository.dart';
import 'data/user.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(tokenStoreProvider),
  ),
);

/// The signed-in user (null when signed out). Loads from the stored token on start.
final authControllerProvider =
    AsyncNotifierProvider<AuthController, User?>(AuthController.new);

class AuthController extends AsyncNotifier<User?> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  Future<User?> build() => _repo.currentUser();

  /// Throws the [ApiException] on failure so the form can show it; state is
  /// only replaced on success.
  Future<void> signIn(String email, String password) async {
    final user = await _repo.signIn(email: email, password: password);
    state = AsyncData(user);
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AsyncData(null);
  }
}
