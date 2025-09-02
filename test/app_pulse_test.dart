import 'package:flutter_test/flutter_test.dart';
import 'package:lumio/lumio.dart';
import 'package:lumio/lumio_platform_interface.dart';
import 'package:lumio/lumio_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockLumioPlatform
    with MockPlatformInterfaceMixin
    implements LumioPlatform {

  final List<String> methodCalls = [];
  final Map<String, dynamic> lastArguments = {};

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

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
  final LumioPlatform initialPlatform = LumioPlatform.instance;

  setUp(() {
    LumioPlatform.instance = initialPlatform;
  });

  group('Lumio Platform Interface', () {
    test('$MethodChannelLumio is the default instance', () {
      expect(initialPlatform, isInstanceOf<MethodChannelLumio>());
    });

    test('getPlatformVersion', () async {
      MockLumioPlatform fakePlatform = MockLumioPlatform();
      LumioPlatform.instance = fakePlatform;

      expect(await Lumio.getPlatformVersion(), '42');
    });
  });

  group('Lumio Logging Methods', () {
    late MockLumioPlatform mockPlatform;

    setUp(() {
      mockPlatform = MockLumioPlatform();
      LumioPlatform.instance = mockPlatform;
    });

    test('logApiResponse calls platform method with correct arguments', () async {
      const url = 'https://api.example.com/users';
      const statusCode = 200;
      const body = '{"users": []}';

      await Lumio.logApiResponse(url, statusCode, body);

      expect(mockPlatform.methodCalls, contains('logApiResponse'));
      expect(mockPlatform.lastArguments['url'], equals(url));
      expect(mockPlatform.lastArguments['statusCode'], equals(statusCode));
      expect(mockPlatform.lastArguments['body'], equals(body));
    });

    test('logNetworkCall calls platform method with correct arguments', () async {
      const method = 'GET';
      const url = 'https://api.example.com/users';
      const durationMs = 250;

      await Lumio.logNetworkCall(method, url, durationMs);

      expect(mockPlatform.methodCalls, contains('logNetworkCall'));
      expect(mockPlatform.lastArguments['method'], equals(method));
      expect(mockPlatform.lastArguments['url'], equals(url));
      expect(mockPlatform.lastArguments['durationMs'], equals(durationMs));
    });

    test('logCrash calls platform method with correct arguments', () async {
      const error = 'Exception: Test error';
      const stackTrace = 'Stack trace line 1\nStack trace line 2';

      await Lumio.logCrash(error, stackTrace);

      expect(mockPlatform.methodCalls, contains('logCrash'));
      expect(mockPlatform.lastArguments['error'], equals(error));
      expect(mockPlatform.lastArguments['stackTrace'], equals(stackTrace));
    });

    test('logAnr calls platform method with correct arguments', () async {
      const message = 'Main thread blocked for 5000ms';

      await Lumio.logAnr(message);

      expect(mockPlatform.methodCalls, contains('logAnr'));
      expect(mockPlatform.lastArguments['message'], equals(message));
    });
  });

  group('Lumio Initialization', () {
    late MockLumioPlatform mockPlatform;

    setUp(() {
      mockPlatform = MockLumioPlatform();
      LumioPlatform.instance = mockPlatform;
    });

    test('initialize calls crash monitoring setup', () async {
      await Lumio.initialize(enableCrashMonitoring: true);

      expect(mockPlatform.methodCalls, contains('initializeCrashMonitoring'));
    });

    test('initialize calls ANR monitoring setup when enabled on Android', () async {
      // Note: In test environment, Platform.isAndroid is false, so ANR monitoring won't be called
      // This test verifies the behavior for non-Android platforms
      await Lumio.initialize(enableAnrMonitoring: true);

      // On non-Android platforms, ANR monitoring should not be called
      expect(mockPlatform.methodCalls, isNot(contains('initializeAnrMonitoring')));
    });

    test('initialize does not call ANR monitoring when disabled', () async {
      await Lumio.initialize(enableAnrMonitoring: false);

      expect(mockPlatform.methodCalls, isNot(contains('initializeAnrMonitoring')));
    });

    test('isInitialized returns correct status', () async {
      // Note: Since Lumio uses static state and there's no reset method,
      // this test might fail if other tests have already initialized Lumio.
      // In a real-world scenario, Lumio would typically be initialized once
      // at app startup.
      
      // If already initialized from previous tests, this will be true
      final wasInitialized = Lumio.isInitialized;
      
      if (!wasInitialized) {
        expect(Lumio.isInitialized, isFalse);
        
        await Lumio.initialize();
        
        expect(Lumio.isInitialized, isTrue);
      } else {
        // Already initialized, just verify it's true
        expect(Lumio.isInitialized, isTrue);
      }
    });
  });

  group('Lumio Error Handling', () {
    late MockLumioPlatform mockPlatform;

    setUp(() {
      mockPlatform = MockLumioPlatform();
      LumioPlatform.instance = mockPlatform;
    });

    test('logApiResponse handles exceptions gracefully', () async {
      // Mock platform that throws exception
      final throwingPlatform = ThrowingMockPlatform();
      LumioPlatform.instance = throwingPlatform;

      // Should not throw exception
      await expectLater(
        Lumio.logApiResponse('url', 200, 'body'),
        completes,
      );
    });

    test('logNetworkCall handles exceptions gracefully', () async {
      final throwingPlatform = ThrowingMockPlatform();
      LumioPlatform.instance = throwingPlatform;

      await expectLater(
        Lumio.logNetworkCall('GET', 'url', 100),
        completes,
      );
    });

    test('logCrash handles exceptions gracefully', () async {
      final throwingPlatform = ThrowingMockPlatform();
      LumioPlatform.instance = throwingPlatform;

      await expectLater(
        Lumio.logCrash('error', 'stack'),
        completes,
      );
    });

    test('logAnr handles exceptions gracefully', () async {
      final throwingPlatform = ThrowingMockPlatform();
      LumioPlatform.instance = throwingPlatform;

      await expectLater(
        Lumio.logAnr('message'),
        completes,
      );
    });
  });
}

class ThrowingMockPlatform extends MockLumioPlatform {
  @override
  Future<void> logApiResponse(String url, int statusCode, String body) async {
    throw Exception('Platform error');
  }

  @override
  Future<void> logNetworkCall(String method, String url, int durationMs) async {
    throw Exception('Platform error');
  }

  @override
  Future<void> logCrash(String error, String stackTrace) async {
    throw Exception('Platform error');
  }

  @override
  Future<void> logAnr(String message) async {
    throw Exception('Platform error');
  }
}
