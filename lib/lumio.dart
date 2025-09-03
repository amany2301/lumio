
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

import 'lumio_platform_interface.dart';
import 'src/models/lumio_models.dart';
import 'src/utils/lumio_storage.dart';
import 'src/utils/lumio_notification.dart';
import 'src/interceptors/lumio_http_interceptor.dart';
import 'src/interceptors/lumio_global_interceptor.dart';
import 'src/interceptors/lumio_dio_interceptor.dart';
import 'src/interceptors/lumio_auto_detector.dart';
import 'src/ui/lumio_debug_ui.dart';

// Models
export 'src/models/lumio_models.dart';

// HTTP Client
export 'src/interceptors/lumio_http_interceptor.dart';

// Dio Client
export 'src/interceptors/lumio_dio_interceptor.dart';

// Auto Detector
export 'src/interceptors/lumio_auto_detector.dart';

// Logger
export 'src/utils/lumio_logger.dart';

// Storage
export 'src/utils/lumio_storage.dart';

// Notification
export 'src/utils/lumio_notification.dart';

// Debug UI
export 'src/ui/lumio_debug_ui.dart';

/// Optimized Lumio - A comprehensive monitoring and logging SDK for Flutter applications
/// Similar to Android Pluto, provides debug interface with notification access
class Lumio {
  // State management
  static bool _isInitialized = false;
  static bool _crashMonitoringEnabled = false;
  static bool _anrMonitoringEnabled = false;
  static bool _notificationShown = false;
  static bool _globalHookEnabled = false;
  static bool _autoDetectionEnabled = false;
  
  // Resource management
  static Timer? _notificationUpdateTimer;
  static Timer? _cleanupTimer;
  static http.Client? _originalClient;
  
  // Performance settings
  static const Duration _notificationUpdateInterval = Duration(seconds: 5);
  static const Duration _cleanupInterval = Duration(minutes: 5);

  /// Initialize Lumio monitoring with sensible defaults
  /// Just call this one line in your main() function
  /// Automatically hooks into all HTTP calls globally and detects Dio usage
  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize with all features enabled by default
    await initializeWithConfig(
      enableCrashMonitoring: true,
      enableAnrMonitoring: true,
      enableNotification: true,
      enableGlobalHttpHook: true,
      enableAutoDetection: true, // Enable auto-detection by default
      maxLogEntries: 1000,
    );
  }

  /// Initialize Lumio with custom configuration
  static Future<void> initializeWithConfig({
    bool enableCrashMonitoring = true,
    bool enableAnrMonitoring = true,
    bool enableNotification = true,
    bool enableGlobalHttpHook = true,
    bool enableAutoDetection = true,
    int maxLogEntries = 1000,
  }) async {
    if (_isInitialized) return;

    try {
      // Initialize storage with optimized settings
      await LumioStorage.initialize();
      await LumioStorage.setMaxLogs(maxLogEntries);

      // Initialize features based on configuration
      if (enableCrashMonitoring) {
        await initializeCrashMonitoring();
      }

      if (enableAnrMonitoring && Platform.isAndroid) {
        await initializeAnrMonitoring();
      }

      if (enableNotification && kDebugMode) {
        await _initializeNotification();
      }

      if (enableGlobalHttpHook) {
        await _enableGlobalHttpHook();
      }

      if (enableAutoDetection) {
        await _enableAutoDetection();
      }

      // Start cleanup timer for resource management
      _startCleanupTimer();

      _isInitialized = true;
      debugPrint('Lumio: Initialized successfully with all features');
    } catch (e) {
      debugPrint('Lumio: Initialization failed: $e');
      rethrow;
    }
  }

  /// Enable global HTTP hook to intercept all HTTP calls
  static Future<void> _enableGlobalHttpHook() async {
    if (_globalHookEnabled) return;

    try {
      await LumioGlobalInterceptor.enable();
      _globalHookEnabled = true;
      debugPrint('Lumio: Global HTTP hook enabled');
    } catch (e) {
      debugPrint('Lumio: Failed to enable global HTTP hook: $e');
    }
  }

  /// Enable auto-detection mode to automatically inject interceptors
  static Future<void> _enableAutoDetection() async {
    if (_autoDetectionEnabled) return;

    try {
      await LumioAutoDetector.enable();
      _autoDetectionEnabled = true;
      debugPrint('Lumio: Auto-detection mode enabled');
    } catch (e) {
      debugPrint('Lumio: Failed to enable auto-detection: $e');
    }
  }

  /// Start cleanup timer for resource management
  static void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(_cleanupInterval, (timer) {
      _performCleanup();
    });
  }

  /// Perform periodic cleanup operations
  static void _performCleanup() {
    try {
      // Clean up auto-detector resources
      LumioAutoDetector.cleanup();
      
      // Update notification if needed
      _updateNotificationIfNeeded();
      
      debugPrint('Lumio: Cleanup completed');
    } catch (e) {
      debugPrint('Lumio: Cleanup failed: $e');
    }
  }

  /// Get platform version
  static Future<String?> getPlatformVersion() {
    return LumioPlatform.instance.getPlatformVersion();
  }

  /// Log API response with optimized performance
  static Future<void> logApiResponse(String url, int statusCode, String body) async {
    try {
      final log = ApiResponseLog(
        url: url,
        statusCode: statusCode,
        body: body,
        timestamp: DateTime.now(),
      );
      
      await LumioStorage.addApiResponse(log);
      await LumioPlatform.instance.logApiResponse(url, statusCode, body);
      _updateNotificationIfNeeded();
    } catch (e) {
      debugPrint('Lumio: Failed to log API response: $e');
    }
  }

  /// Log network call with optimized performance
  static Future<void> logNetworkCall(String method, String url, int durationMs) async {
    try {
      final log = NetworkCallLog(
        method: method,
        url: url,
        durationMs: durationMs,
        timestamp: DateTime.now(),
      );
      
      await LumioStorage.addNetworkCall(log);
      await LumioPlatform.instance.logNetworkCall(method, url, durationMs);
      _updateNotificationIfNeeded();
    } catch (e) {
      debugPrint('Lumio: Failed to log network call: $e');
    }
  }

  /// Log crash with optimized performance
  static Future<void> logCrash(String error, String stackTrace) async {
    try {
      final log = CrashLog(
        error: error,
        stackTrace: stackTrace,
        timestamp: DateTime.now(),
      );
      
      await LumioStorage.addCrash(log);
      await LumioPlatform.instance.logCrash(error, stackTrace);
      _updateNotificationIfNeeded();
    } catch (e) {
      debugPrint('Lumio: Failed to log crash: $e');
    }
  }

  /// Log ANR with optimized performance
  static Future<void> logAnr(String message) async {
    try {
      final log = AnrLog(
        message: message,
        timestamp: DateTime.now(),
      );
      
      await LumioStorage.addAnr(log);
      await LumioPlatform.instance.logAnr(message);
      _updateNotificationIfNeeded();
    } catch (e) {
      debugPrint('Lumio: Failed to log ANR: $e');
    }
  }

  /// Initialize crash monitoring with optimized error handling
  static Future<void> initializeCrashMonitoring() async {
    if (_crashMonitoringEnabled) return;

    try {
      // Setup Flutter error handling
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        logCrash(
          details.exception.toString(),
          details.stack?.toString() ?? 'No stack trace available',
        );
      };

      // Setup platform error handling
      PlatformDispatcher.instance.onError = (error, stack) {
        logCrash(error.toString(), stack.toString());
        return true;
      };

      await LumioPlatform.instance.initializeCrashMonitoring();
      _crashMonitoringEnabled = true;
      debugPrint('Lumio: Crash monitoring initialized');
    } catch (e) {
      debugPrint('Lumio: Failed to initialize crash monitoring: $e');
    }
  }

  /// Initialize ANR monitoring (Android only)
  static Future<void> initializeAnrMonitoring() async {
    if (_anrMonitoringEnabled || !Platform.isAndroid) return;

    try {
      await LumioPlatform.instance.initializeAnrMonitoring();
      _anrMonitoringEnabled = true;
      debugPrint('Lumio: ANR monitoring initialized');
    } catch (e) {
      debugPrint('Lumio: Failed to initialize ANR monitoring: $e');
    }
  }

  /// Initialize notification system with optimized settings
  static Future<void> _initializeNotification() async {
    try {
      await LumioNotification.initialize();
      await LumioNotification.showDebugNotification();
      _notificationShown = true;

      // Start periodic notification updates
      _notificationUpdateTimer = Timer.periodic(_notificationUpdateInterval, (timer) {
        _updateNotificationIfNeeded();
      });
      
      debugPrint('Lumio: Notification system initialized');
    } catch (e) {
      debugPrint('Lumio: Failed to initialize notification: $e');
    }
  }

  /// Update notification with current log counts (optimized)
  static Future<void> _updateNotificationIfNeeded() async {
    if (!_notificationShown || !kDebugMode) return;

    try {
      final counts = await LumioStorage.getLogCounts();
      await LumioNotification.updateNotificationWithCounts(counts);
    } catch (e) {
      debugPrint('Lumio: Failed to update notification: $e');
    }
  }

  /// Show debug UI with optimized navigation
  static void showDebugUI(BuildContext context) {
    if (!_isInitialized) {
      debugPrint('Lumio: Not initialized. Call Lumio.initialize() first.');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LumioDebugUI(),
      ),
    );
  }

  /// Get HTTP client with Lumio interceptor
  static http.Client get httpClient => LumioHttpClient.client;

  /// Get Dio instance with Lumio interceptor
  static Dio get dioClient => LumioDio.dio;

  /// Get comprehensive status information
  static Map<String, dynamic> get status {
    return {
      'isInitialized': _isInitialized,
      'crashMonitoringEnabled': _crashMonitoringEnabled,
      'anrMonitoringEnabled': _anrMonitoringEnabled,
      'notificationShown': _notificationShown,
      'globalHookEnabled': _globalHookEnabled,
      'autoDetectionEnabled': _autoDetectionEnabled,
      'storageInitialized': LumioStorage.isInitialized,
      'autoDetectorStats': LumioAutoDetector.statistics,
    };
  }

  /// Check if Lumio is initialized
  static bool get isInitialized => _isInitialized;

  /// Check if crash monitoring is enabled
  static bool get isCrashMonitoringEnabled => _crashMonitoringEnabled;

  /// Check if ANR monitoring is enabled
  static bool get isAnrMonitoringEnabled => _anrMonitoringEnabled;

  /// Check if notification is shown
  static bool get isNotificationShown => _notificationShown;

  /// Check if global HTTP hook is enabled
  static bool get isGlobalHookEnabled => _globalHookEnabled;

  /// Check if auto-detection is enabled
  static bool get isAutoDetectionEnabled => _autoDetectionEnabled;

  /// Export all data with optimized performance
  static Future<Map<String, dynamic>> exportAllData() async {
    try {
      final networkCalls = await LumioStorage.getNetworkCalls();
      final apiResponses = await LumioStorage.getApiResponses();
      final crashes = await LumioStorage.getCrashes();
      final anrs = await LumioStorage.getAnrs();

      return {
        'initialized': _isInitialized,
        'crashMonitoringEnabled': _crashMonitoringEnabled,
        'anrMonitoringEnabled': _anrMonitoringEnabled,
        'notificationShown': _notificationShown,
        'globalHookEnabled': _globalHookEnabled,
        'autoDetectionEnabled': _autoDetectionEnabled,
        'networkCalls': networkCalls.map((log) => log.toJson()).toList(),
        'apiResponses': apiResponses.map((log) => log.toJson()).toList(),
        'crashes': crashes.map((log) => log.toJson()).toList(),
        'anrs': anrs.map((log) => log.toJson()).toList(),
        'exportTimestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Lumio: Export failed: $e');
      rethrow;
    }
  }

  /// Clear all logs with optimized operation
  static Future<void> clearAllLogs() async {
    try {
      await LumioStorage.clearAllLogs();
      _updateNotificationIfNeeded();
      debugPrint('Lumio: All logs cleared');
    } catch (e) {
      debugPrint('Lumio: Failed to clear logs: $e');
      rethrow;
    }
  }

  /// Dispose Lumio with comprehensive cleanup
  static void dispose() {
    try {
      // Cancel timers
      _notificationUpdateTimer?.cancel();
      _cleanupTimer?.cancel();
      
      // Hide notification
      LumioNotification.hideDebugNotification();
      
      // Dispose HTTP clients
      LumioHttpClient.dispose();
      LumioGlobalInterceptor.disable();
      LumioDio.dispose();
      
      // Disable auto-detection
      LumioAutoDetector.disable();
      
      // Dispose storage
      LumioStorage.dispose();
      
      // Reset state
      _isInitialized = false;
      _crashMonitoringEnabled = false;
      _anrMonitoringEnabled = false;
      _notificationShown = false;
      _globalHookEnabled = false;
      _autoDetectionEnabled = false;
      
      debugPrint('Lumio: Disposed successfully');
    } catch (e) {
      debugPrint('Lumio: Dispose failed: $e');
    }
  }
}
