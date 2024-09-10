import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/token_store.dart';
import 'user.dart';

class AuthRepository {
  AuthRepository(this._api, this._tokens);

  final ApiClient _api;
  final TokenStore _tokens;

  /// Exchanges credentials for a device token and keeps it in secure storage.
  Future<User> signIn({
    required String email,
    required String password,
    String deviceName = 'Finance Tracker mobile',
  }) async {
    final body = await _api.post('/session', {
      'email': email.trim(),
      'password': password,
      'device_name': deviceName,
    });
    await _tokens.write(body['token'] as String);
    return User.fromJson(body['user'] as Map<String, dynamic>);
  }

  /// The signed-in user, or null when there is no token or it was revoked.
  Future<User?> currentUser() async {
    if (await _tokens.read() == null) return null;
    try {
      return User.fromJson(await _api.get('/me'));
    } on UnauthorizedException {
      await _tokens.clear();
      return null;
    }
  }

  /// Revokes the token on the server (best effort) and forgets it locally.
  Future<void> signOut() async {
    try {
      await _api.delete('/session');
    } on ApiException {
      // Offline or already revoked: forgetting it locally is what matters.
    }
    await _tokens.clear();
  }
}
