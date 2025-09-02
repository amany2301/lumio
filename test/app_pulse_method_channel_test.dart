import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumio/lumio_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelLumio platform = MethodChannelLumio();
  const MethodChannel channel = MethodChannel('lumio');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'getPlatformVersion':
            return '42';
          case 'logApiResponse':
          case 'logNetworkCall':
          case 'logCrash':
          case 'logAnr':
          case 'initializeCrashMonitoring':
          case 'initializeAnrMonitoring':
            return null; // Successful completion
          default:
            throw MissingPluginException('No implementation found for method ${methodCall.method}');
        }
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  group('MethodChannelAppPulse', () {
    test('getPlatformVersion', () async {
      expect(await platform.getPlatformVersion(), '42');
    });

    test('logApiResponse calls correct method with arguments', () async {
      final List<MethodCall> log = <MethodCall>[];
      
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async {
          log.add(methodCall);
          return null;
        },
      );

      await platform.logApiResponse('https://api.example.com', 200, '{"test": true}');

      expect(log, hasLength(1));
      expect(log.first.method, 'logApiResponse');
      expect(log.first.arguments, {
        'url': 'https://api.example.com',
        'statusCode': 200,
        'body': '{"test": true}',
      });
    });

    test('logNetworkCall calls correct method with arguments', () async {
      final List<MethodCall> log = <MethodCall>[];
      
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async {
          log.add(methodCall);
          return null;
        },
      );

      await platform.logNetworkCall('GET', 'https://api.example.com', 250);

      expect(log, hasLength(1));
      expect(log.first.method, 'logNetworkCall');
      expect(log.first.arguments, {
        'method': 'GET',
        'url': 'https://api.example.com',
        'durationMs': 250,
      });
    });

    test('logCrash calls correct method with arguments', () async {
      final List<MethodCall> log = <MethodCall>[];
      
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async {
          log.add(methodCall);
          return null;
        },
      );

      await platform.logCrash('Test error', 'Stack trace');

      expect(log, hasLength(1));
      expect(log.first.method, 'logCrash');
      expect(log.first.arguments, {
        'error': 'Test error',
        'stackTrace': 'Stack trace',
      });
    });

    test('logAnr calls correct method with arguments', () async {
      final List<MethodCall> log = <MethodCall>[];
      
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async {
          log.add(methodCall);
          return null;
        },
      );

      await platform.logAnr('ANR detected');

      expect(log, hasLength(1));
      expect(log.first.method, 'logAnr');
      expect(log.first.arguments, {
        'message': 'ANR detected',
      });
    });

    test('initializeCrashMonitoring calls correct method', () async {
      final List<MethodCall> log = <MethodCall>[];
      
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async {
          log.add(methodCall);
          return null;
        },
      );

      await platform.initializeCrashMonitoring();

      expect(log, hasLength(1));
      expect(log.first.method, 'initializeCrashMonitoring');
      expect(log.first.arguments, isNull);
    });

    test('initializeAnrMonitoring calls correct method', () async {
      final List<MethodCall> log = <MethodCall>[];
      
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async {
          log.add(methodCall);
          return null;
        },
      );

      await platform.initializeAnrMonitoring();

      expect(log, hasLength(1));
      expect(log.first.method, 'initializeAnrMonitoring');
      expect(log.first.arguments, isNull);
    });

    test('handles platform exceptions', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async {
          throw PlatformException(code: 'TEST_ERROR', message: 'Test error');
        },
      );

      expect(
        () => platform.getPlatformVersion(),
        throwsA(isA<PlatformException>()),
      );
    });
  });
}
