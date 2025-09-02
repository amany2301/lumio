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
        });
      });
    });

    group('LumioConfig', () {
      test('creates instance with default values', () {
        const config = LumioConfig();

        expect(config.enableCrashMonitoring, isTrue);
        expect(config.enableAnrMonitoring, isTrue);
        expect(config.enableNetworkLogging, isTrue);
        expect(config.enableApiResponseLogging, isTrue);
        expect(config.maxLogEntries, equals(1000));
      });

      test('creates instance with custom values', () {
        const config = LumioConfig(
          enableCrashMonitoring: false,
          enableAnrMonitoring: false,
          enableNetworkLogging: false,
          enableApiResponseLogging: false,
          maxLogEntries: 500,
        );

        expect(config.enableCrashMonitoring, isFalse);
        expect(config.enableAnrMonitoring, isFalse);
        expect(config.enableNetworkLogging, isFalse);
        expect(config.enableApiResponseLogging, isFalse);
        expect(config.maxLogEntries, equals(500));
      });

      test('creates instance with partial custom values', () {
        const config = LumioConfig(
          enableCrashMonitoring: false,
          maxLogEntries: 2000,
        );

        expect(config.enableCrashMonitoring, isFalse);
        expect(config.enableAnrMonitoring, isTrue); // default
        expect(config.enableNetworkLogging, isTrue); // default
        expect(config.enableApiResponseLogging, isTrue); // default
        expect(config.maxLogEntries, equals(2000));
      });
    });
  });
}
