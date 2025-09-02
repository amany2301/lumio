
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'lumio_platform_interface.dart';

// Core debugging components
export 'src/debug_ui/lumio_debug_overlay.dart';
export 'src/interceptors/lumio_http_interceptor.dart';
export 'src/utils/lumio_logger.dart';

/// Lumio - On-device debugging framework for Flutter applications
/// 
/// Features:
/// - HTTP request/response inspection
/// - Crash and ANR capture
/// - On-device UI for monitoring
/// - APIs to access debugging information
class Lumio {
  static bool _isInitialized = false;
  static bool _crashMonitoringEnabled = false;
  static bool _anrMonitoringEnabled = false;

  /// Initialize Lumio debugging framework
  static Future<void> initialize({
    bool enableCrashMonitoring = true,
    bool enableAnrMonitoring = true,
  }) async {
    if (_isInitialized) return;

    if (enableCrashMonitoring) {
      await initializeCrashMonitoring();
    }

    if (enableAnrMonitoring && Platform.isAndroid) {
      await initializeAnrMonitoring();
    }

    _isInitialized = true;
  }

  /// Get platform version
  static Future<String?> getPlatformVersion() {
    return LumioPlatform.instance.getPlatformVersion();
  }

  /// Log HTTP request/response for inspection
  static Future<void> logHttpRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    String? body,
  }) async {
    try {
      await LumioPlatform.instance.logHttpRequest(method, url, headers, body);
    } catch (e) {
      debugPrint('Lumio: Failed to log HTTP request: $e');
    }
  }

  /// Log HTTP response for inspection
  static Future<void> logHttpResponse({
    required String url,
    required int statusCode,
    required String body,
    Map<String, String>? headers,
    int? durationMs,
  }) async {
    try {
      await LumioPlatform.instance.logHttpResponse(url, statusCode, body, headers, durationMs);
    } catch (e) {
      debugPrint('Lumio: Failed to log HTTP response: $e');
    }
  }

  /// Log crash with error message and stack trace
  static Future<void> logCrash(String error, String stackTrace) async {
    try {
      await LumioPlatform.instance.logCrash(error, stackTrace);
    } catch (e) {
      debugPrint('Lumio: Failed to log crash: $e');
    }
  }

  /// Log ANR (Application Not Responding) event
  static Future<void> logAnr(String message) async {
    try {
      await LumioPlatform.instance.logAnr(message);
    } catch (e) {
      debugPrint('Lumio: Failed to log ANR: $e');
    }
  }

  /// Initialize crash monitoring
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
    } catch (e) {
      debugPrint('Lumio: Failed to initialize ANR monitoring: $e');
    }
  }

  /// Check if Lumio is initialized
  static bool get isInitialized => _isInitialized;

  /// Check if crash monitoring is enabled
  static bool get isCrashMonitoringEnabled => _crashMonitoringEnabled;

  /// Check if ANR monitoring is enabled
  static bool get isAnrMonitoringEnabled => _anrMonitoringEnabled;
}
