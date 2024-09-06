/// Failures from the Finance Tracker API, mapped from HTTP status codes so the
/// UI can react to the kind of problem rather than to raw responses.
sealed class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// No connection, DNS failure or timeout. Safe to retry later.
final class NetworkException extends ApiException {
  const NetworkException([super.message = 'No connection to the server']);
}

/// 401: missing, revoked or wrong credentials.
final class UnauthorizedException extends ApiException {
  const UnauthorizedException(super.message);
}

/// 404: not found (or belongs to someone else).
final class NotFoundException extends ApiException {
  const NotFoundException(super.message);
}

/// 409: the server copy changed since we last synced.
final class ConflictException extends ApiException {
  const ConflictException(super.message, {this.serverCopy});
  final Map<String, dynamic>? serverCopy;
}

/// 422: validation failed; [fieldErrors] maps field names to messages.
final class ValidationException extends ApiException {
  const ValidationException(super.message, {this.fieldErrors = const {}});
  final Map<String, List<String>> fieldErrors;
}

/// 429: too many requests.
final class RateLimitedException extends ApiException {
  const RateLimitedException([
    super.message = 'Too many requests, try again shortly',
  ]);
}

/// Anything else (5xx, unexpected payloads).
final class ServerException extends ApiException {
  const ServerException(super.message, {this.statusCode});
  final int? statusCode;
}
