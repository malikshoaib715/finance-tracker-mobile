import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:finance_tracker_mobile/core/api/api_client.dart';
import 'package:finance_tracker_mobile/core/api/api_exception.dart';
import 'package:flutter_test/flutter_test.dart';

/// Answers every request with a fixed status and JSON body, recording the request.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.status, this.body);
  final int status;
  final Object? body;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

ApiClient clientWith(FakeAdapter adapter, {String? token = 'ft_test'}) {
  final dio = Dio()..httpClientAdapter = adapter;
  return ApiClient(
    baseUrl: 'https://example.test',
    tokenProvider: () async => token,
    dio: dio,
  );
}

void main() {
  test('sends the bearer token and returns the JSON body', () async {
    final adapter = FakeAdapter(200, {'email': 'demo@example.com'});
    final body = await clientWith(adapter).get('/me');

    expect(body['email'], 'demo@example.com');
    expect(adapter.lastRequest!.headers['Authorization'], 'Bearer ft_test');
    expect(
      adapter.lastRequest!.uri.toString(),
      'https://example.test/api/v1/me',
    );
  });

  test('omits the header when signed out', () async {
    final adapter = FakeAdapter(200, {});
    await clientWith(adapter, token: null).get('/me');
    expect(adapter.lastRequest!.headers.containsKey('Authorization'), isFalse);
  });

  test('maps 401 to UnauthorizedException with the server message', () async {
    final adapter = FakeAdapter(401, {
      'error': {'message': 'Missing or invalid API token'},
    });
    expect(
      () => clientWith(adapter).get('/me'),
      throwsA(
        isA<UnauthorizedException>().having(
          (e) => e.message,
          'message',
          'Missing or invalid API token',
        ),
      ),
    );
  });

  test('maps 422 to ValidationException with field errors', () async {
    final adapter = FakeAdapter(422, {
      'error': {
        'message': "Description can't be blank",
        'details': {
          'description': ["can't be blank"],
        },
      },
    });
    try {
      await clientWith(adapter).post('/transactions', {});
      fail('expected a ValidationException');
    } on ValidationException catch (e) {
      expect(e.fieldErrors['description'], ["can't be blank"]);
    }
  });

  test('maps 409 to ConflictException with the server copy', () async {
    final adapter = FakeAdapter(409, {
      'error': {'message': 'Changed on the server'},
      'transaction': {'id': 7, 'description': 'Rent'},
    });
    try {
      await clientWith(adapter).patch('/transactions/7', {});
      fail('expected a ConflictException');
    } on ConflictException catch (e) {
      expect(e.serverCopy!['description'], 'Rent');
    }
  });

  test('maps 5xx to ServerException', () async {
    final adapter = FakeAdapter(503, 'unavailable');
    expect(
      () => clientWith(adapter).get('/me'),
      throwsA(
        isA<ServerException>().having((e) => e.statusCode, 'status', 503),
      ),
    );
  });
}
