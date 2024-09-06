import 'package:dio/dio.dart';

import 'api_exception.dart';

/// Thin wrapper around Dio for the Finance Tracker JSON API (v1).
///
/// Adds the bearer token, JSON headers and timeouts, and turns every failure
/// into an [ApiException] subtype.
class ApiClient {
  ApiClient({
    required String baseUrl,
    required Future<String?> Function() tokenProvider,
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = '$baseUrl/api/v1'
      ..connectTimeout = const Duration(seconds: 10)
      ..receiveTimeout = const Duration(seconds: 20)
      ..headers = {'Accept': 'application/json'}
      ..contentType = Headers.jsonContentType;
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenProvider();
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) =>
      _send(() => _dio.get<Map<String, dynamic>>(path, queryParameters: query));

  Future<Map<String, dynamic>> post(String path, Object body) =>
      _send(() => _dio.post<Map<String, dynamic>>(path, data: body));

  Future<Map<String, dynamic>> patch(String path, Object body) =>
      _send(() => _dio.patch<Map<String, dynamic>>(path, data: body));

  Future<void> delete(String path) => _send(() => _dio.delete<Object?>(path));

  Future<Map<String, dynamic>> _send<T>(
    Future<Response<T>> Function() request,
  ) async {
    try {
      final response = await request();
      final data = response.data;
      return data is Map<String, dynamic> ? data : const {};
    } on DioException catch (e) {
      throw mapError(e);
    }
  }

  static ApiException mapError(DioException e) {
    final response = e.response;
    if (response == null) return const NetworkException();

    final body = response.data;
    final error = body is Map<String, dynamic> ? body['error'] : null;
    final message = error is Map<String, dynamic>
        ? (error['message'] as String? ?? 'Request failed')
        : 'Request failed (${response.statusCode})';

    return switch (response.statusCode) {
      401 => UnauthorizedException(message),
      404 => NotFoundException(message),
      409 => ConflictException(
          message,
          serverCopy: body is Map<String, dynamic>
              ? body['transaction'] as Map<String, dynamic>?
              : null,
        ),
      422 => ValidationException(message, fieldErrors: _fieldErrors(error)),
      429 => const RateLimitedException(),
      _ => ServerException(message, statusCode: response.statusCode),
    };
  }

  static Map<String, List<String>> _fieldErrors(Object? error) {
    final details = error is Map<String, dynamic> ? error['details'] : null;
    if (details is! Map<String, dynamic>) return const {};
    return details.map(
      (field, messages) =>
          MapEntry(field, (messages as List<dynamic>).cast<String>()),
    );
  }
}
