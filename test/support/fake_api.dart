import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:finance_tracker_mobile/core/api/api_client.dart';

typedef FakeResponse = (int status, Object? body);

/// Routes requests by "METHOD /path" to canned responses and records them.
class FakeApi implements HttpClientAdapter {
  final Map<String, FakeResponse Function(RequestOptions)> routes = {};
  final List<RequestOptions> requests = [];

  void on(String route, FakeResponse response) =>
      routes[route] = (_) => response;

  void onDynamic(String route, FakeResponse Function(RequestOptions) handler) =>
      routes[route] = handler;

  ApiClient client({String? token = 'ft_test'}) => ApiClient(
        baseUrl: 'https://example.test',
        tokenProvider: () async => token,
        dio: Dio()..httpClientAdapter = this,
      );

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final path = options.uri.path.replaceFirst('/api/v1', '');
    final handler = routes['${options.method} $path'];
    if (handler == null) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'No fake route for ${options.method} $path',
      );
    }
    final (status, body) = handler(options);
    return ResponseBody.fromString(
      body == null ? '' : jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
