import 'package:flutter_test/flutter_test.dart';
import 'package:lumio/src/models/lumio_models.dart';

void main() {
  group('Lumio Models', () {
    group('NetworkCallLog', () {
      test('creates instance with all required fields', () {
        final timestamp = DateTime.now();
        final log = NetworkCallLog(
          method: 'GET',
          url: 'https://api.example.com',
          durationMs: 250,
          timestamp: timestamp,
        );

        expect(log.method, equals('GET'));
        expect(log.url, equals('https://api.example.com'));
        expect(log.durationMs, equals(250));
        expect(log.timestamp, equals(timestamp));
      });

      test('toJson returns correct map', () {
        final timestamp = DateTime(2023, 1, 1, 12, 0, 0);
        final log = NetworkCallLog(
          method: 'POST',
          url: 'https://api.example.com/users',
          durationMs: 500,
          timestamp: timestamp,
        );

        final json = log.toJson();

        expect(json, {
          'method': 'POST',
          'url': 'https://api.example.com/users',
          'durationMs': 500,
          'timestamp': timestamp.toIso8601String(),
          'error': null,
          'headers': null,
          'requestBody': null,
          'statusCode': null,
        });
      });
    });

    group('ApiResponseLog', () {
      test('creates instance with all required fields', () {
        final timestamp = DateTime.now();
        final log = ApiResponseLog(
          url: 'https://api.example.com',
          statusCode: 200,
          body: '{"success": true}',
          timestamp: timestamp,
        );

        expect(log.url, equals('https://api.example.com'));
        expect(log.statusCode, equals(200));
        expect(log.body, equals('{"success": true}'));
        expect(log.timestamp, equals(timestamp));
      });

      test('toJson returns correct map', () {
        final timestamp = DateTime(2023, 1, 1, 12, 0, 0);
        final log = ApiResponseLog(
          url: 'https://api.example.com/posts',
          statusCode: 201,
          body: '{"id": 1, "title": "Test"}',
          timestamp: timestamp,
        );

        final json = log.toJson();

        expect(json, {
          'url': 'https://api.example.com/posts',
          'statusCode': 201,
          'body': '{"id": 1, "title": "Test"}',
          'timestamp': timestamp.toIso8601String(),
          'headers': null,
          'responseSize': 26,
        });
      });
    });

    group('CrashLog', () {
      test('creates instance with all required fields', () {
        final timestamp = DateTime.now();
        final log = CrashLog(
          error: 'Exception: Test error',
          stackTrace: 'Stack trace line 1\nStack trace line 2',
          timestamp: timestamp,
        );

        expect(log.error, equals('Exception: Test error'));
        expect(log.stackTrace, equals('Stack trace line 1\nStack trace line 2'));
        expect(log.timestamp, equals(timestamp));
      });

      test('toJson returns correct map', () {
        final timestamp = DateTime(2023, 1, 1, 12, 0, 0);
        final log = CrashLog(
          error: 'NullPointerException',
          stackTrace: 'at main.dart:123\nat widget.dart:456',
          timestamp: timestamp,
        );

        final json = log.toJson();

        expect(json, {
          'error': 'NullPointerException',
          'stackTrace': 'at main.dart:123\nat widget.dart:456',
          'timestamp': timestamp.toIso8601String(),
          'type': null,
          'metadata': null,
        });
      });
    });

    group('AnrLog', () {
      test('creates instance with all required fields', () {
        final timestamp = DateTime.now();
        final log = AnrLog(
          message: 'Main thread blocked for 5000ms',
          timestamp: timestamp,
        );

        expect(log.message, equals('Main thread blocked for 5000ms'));
        expect(log.timestamp, equals(timestamp));
      });

      test('toJson returns correct map', () {
        final timestamp = DateTime(2023, 1, 1, 12, 0, 0);
        final log = AnrLog(
          message: 'ANR detected during heavy computation',
          timestamp: timestamp,
        );

        final json = log.toJson();

        expect(json, {
          'message': 'ANR detected during heavy computation',
          'timestamp': timestamp.toIso8601String(),
          'durationMs': null,
          'threadInfo': null,
          'metadata': null,
        });
      });
    });

    group('LogSummary', () {
      test('creates summary from logs', () {
        final networkCalls = [
          NetworkCallLog(
            method: 'GET',
            url: 'https://api.example.com/data',
            durationMs: 100,
            timestamp: DateTime.now(),
          ),
        ];
        
        final apiResponses = [
          ApiResponseLog(
            url: 'https://api.example.com/data',
            statusCode: 200,
            body: '{"data": "test"}',
            timestamp: DateTime.now(),
          ),
        ];
        
        final crashes = [
          CrashLog(
            error: 'Test error',
            stackTrace: 'Stack trace',
            timestamp: DateTime.now(),
          ),
        ];
        
        final anrs = [
          AnrLog(
            message: 'ANR detected',
            timestamp: DateTime.now(),
          ),
        ];

        final summary = LogSummary.fromLogs(
          networkCalls: networkCalls,
          apiResponses: apiResponses,
          crashes: crashes,
          anrs: anrs,
        );

        expect(summary.totalLogs, equals(4));
        expect(summary.networkCalls, equals(1));
        expect(summary.apiResponses, equals(1));
        expect(summary.crashes, equals(1));
        expect(summary.anrs, equals(1));
        expect(summary.statusCodes['200'], equals(1));
        expect(summary.errorTypes['Unknown'], equals(1));
      });
    });
  });
}
