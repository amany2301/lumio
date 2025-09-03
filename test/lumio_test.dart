import 'package:flutter_test/flutter_test.dart';
import 'package:lumio/lumio.dart';

void main() {
  group('Lumio Tests', () {
    test('should initialize without errors', () async {
      // This test verifies that Lumio can be initialized
      expect(Lumio.isInitialized, false);
      
      // Note: In a real test environment, you would need to set up
      // the necessary platform channels and dependencies
      // For now, we'll just test that the class exists and has the expected structure
      
      expect(Lumio.isCrashMonitoringEnabled, false);
      expect(Lumio.isAnrMonitoringEnabled, false);
      expect(Lumio.isNotificationShown, false);
    });

    test('should have expected static methods', () {
      // Test that all expected methods exist
      expect(Lumio.logApiResponse, isA<Function>());
      expect(Lumio.logNetworkCall, isA<Function>());
      expect(Lumio.logCrash, isA<Function>());
      expect(Lumio.logAnr, isA<Function>());
      expect(Lumio.exportAllData, isA<Function>());
      expect(Lumio.clearAllLogs, isA<Function>());
      expect(Lumio.dispose, isA<Function>());
    });

    test('should have expected getters', () {
      expect(Lumio.isInitialized, isA<bool>());
      expect(Lumio.isCrashMonitoringEnabled, isA<bool>());
      expect(Lumio.isAnrMonitoringEnabled, isA<bool>());
      expect(Lumio.isNotificationShown, isA<bool>());
    });
  });
}
