import 'package:flutter_test/flutter_test.dart';
import 'package:lumio/src/interceptors/lumio_http_interceptor.dart';
import 'package:lumio/lumio.dart';
import 'package:lumio/lumio_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockLumioPlatform
    with MockPlatformInterfaceMixin
    implements LumioPlatform {

  final List<String> methodCalls = [];
  final Map<String, dynamic> lastArguments = {};

  @override
  Future<String?> getPlatformVersion() => Future.value('Test');

  @override
  Future<void> logApiResponse(String url, int statusCode, String body) async {
    methodCalls.add('logApiResponse');
    lastArguments['url'] = url;
    lastArguments['statusCode'] = statusCode;
    lastArguments['body'] = body;
  }

  @override
  Future<void> logNetworkCall(String method, String url, int durationMs) async {
    methodCalls.add('logNetworkCall');
    lastArguments['method'] = method;
    lastArguments['url'] = url;
    lastArguments['durationMs'] = durationMs;
  }

  @override
  Future<void> logCrash(String error, String stackTrace) async {
    methodCalls.add('logCrash');
    lastArguments['error'] = error;
    lastArguments['stackTrace'] = stackTrace;
  }

  @override
  Future<void> logAnr(String message) async {
    methodCalls.add('logAnr');
    lastArguments['message'] = message;
  }

  @override
  Future<void> initializeCrashMonitoring() async {
    methodCalls.add('initializeCrashMonitoring');
  }

  @override
  Future<void> initializeAnrMonitoring() async {
    methodCalls.add('initializeAnrMonitoring');
  }
}

void main() {
  group('LumioHttpInterceptor', () {
    late MockLumioPlatform mockPlatform;

    setUp(() {
      mockPlatform = MockLumioPlatform();
      LumioPlatform.instance = mockPlatform;
    });

    group('wrapResponse', () {
      test('logs successful network call', () async {
        const method = 'GET';
        const url = 'https://api.example.com/users';
        const result = 'Success';

        final response = await LumioHttpInterceptor.wrapResponse(
          () async => result,
          method,
          url,
        );

        expect(response, equals(result));
        expect(mockPlatform.methodCalls, contains('logNetworkCall'));
        expect(mockPlatform.lastArguments['method'], equals(method));
        expect(mockPlatform.lastArguments['url'], equals(url));
        expect(mockPlatform.lastArguments['durationMs'], isA<int>());
        expect(mockPlatform.lastArguments['durationMs'], greaterThanOrEqualTo(0));
      });

      test('logs failed network call and rethrows exception', () async {
        const method = 'POST';
        const url = 'https://api.example.com/users';
        final exception = Exception('Network error');

        await expectLater(
          LumioHttpInterceptor.wrapResponse(
            () async => throw exception,
            method,
            url,
          ),
          throwsA(equals(exception)),
        );

        expect(mockPlatform.methodCalls, contains('logNetworkCall'));
        expect(mockPlatform.methodCalls, contains('logCrash'));
        expect(mockPlatform.lastArguments['method'], equals(method));
        expect(mockPlatform.lastArguments['url'], equals(url));
        expect(mockPlatform.lastArguments['durationMs'], isA<int>());
      });

      test('measures duration correctly', () async {
        const method = 'GET';
        const url = 'https://api.example.com/test';
        const delayMs = 100;

        await LumioHttpInterceptor.wrapResponse(
          () async {
            await Future.delayed(Duration(milliseconds: delayMs));
            return 'Done';
          },
          method,
          url,
        );

        expect(mockPlatform.methodCalls, contains('logNetworkCall'));
        final duration = mockPlatform.lastArguments['durationMs'] as int;
        // Allow some tolerance for timing variations
        expect(duration, greaterThanOrEqualTo(delayMs - 50));
        expect(duration, lessThan(delayMs + 100));
      });
    });

    group('logResponse', () {
      test('calls Lumio.logApiResponse', () {
        const url = 'https://api.example.com/posts';
        const statusCode = 201;
        const body = '{"id": 1, "title": "Test Post"}';

        LumioHttpInterceptor.logResponse(url, statusCode, body);

        expect(mockPlatform.methodCalls, contains('logApiResponse'));
        expect(mockPlatform.lastArguments['url'], equals(url));
        expect(mockPlatform.lastArguments['statusCode'], equals(statusCode));
        expect(mockPlatform.lastArguments['body'], equals(body));
      });
    });

    group('logError', () {
      test('calls Lumio.logCrash with formatted error', () {
        const url = 'https://api.example.com/error';
        const error = 'Connection timeout';

        LumioHttpInterceptor.logError(url, error);

        expect(mockPlatform.methodCalls, contains('logCrash'));
        expect(mockPlatform.lastArguments['error'], equals('Network Error for $url: $error'));
        expect(mockPlatform.lastArguments['stackTrace'], isA<String>());
        expect(mockPlatform.lastArguments['stackTrace'], isNotEmpty);
      });
    });
  });

  group('LumioHttpClient', () {
    late MockLumioPlatform mockPlatform;

    setUp(() {
      mockPlatform = MockLumioPlatform();
      LumioPlatform.instance = mockPlatform;
    });

    test('creates and closes client', () {
      final client = LumioHttpClient();
      expect(client, isA<LumioHttpClient>());
      
      // Should not throw
      client.close();
    });

    // Note: Testing actual HTTP requests would require mocking HttpClient
    // which is complex. The integration test would be better for this.
  });
}
