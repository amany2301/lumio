
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'lumio_platform_interface.dart';


// Network Plugin
export 'src/plugins/network/network_manager.dart';
export 'src/plugins/network/network_data.dart';
export 'src/plugins/network/network_screen.dart';
export 'src/plugins/network/network_detail_screen.dart';

// Crashes Plugin
export 'src/plugins/crashes/crash_manager.dart';
export 'src/plugins/crashes/crash_data.dart';
export 'src/plugins/crashes/crash_screen.dart';
export 'src/plugins/crashes/crash_detail_screen.dart';

// Logger Plugin
export 'src/plugins/logger/logger_manager.dart';
export 'src/plugins/logger/logger_data.dart';
export 'src/plugins/logger/logger_screen.dart';
export 'src/plugins/logger/log_detail_screen.dart';

// Debug UI Framework
export 'src/debug_ui/app_pulse_debug_overlay.dart';

// Plugin System
export 'src/plugins/plugin_base.dart';
export 'src/plugins/network/network_plugin.dart';
export 'src/plugins/crashes/crash_plugin.dart';
export 'src/plugins/logger/logger_plugin.dart';

/// Lumio - A comprehensive monitoring and logging SDK for Flutter applications
class Lumio {
  static bool _isInitialized = false;
  static bool _crashMonitoringEnabled = false;
  static bool _anrMonitoringEnabled = false;
  static bool _debugOverlayEnabled = false;
  static final PluginRegistry _pluginRegistry = PluginRegistry();

  /// Initialize Lumio monitoring with plugins
  static Future<void> initialize({
    bool enableCrashMonitoring = true,
    bool enableAnrMonitoring = true,
    bool enableDebugOverlay = true,
    List<Plugin>? plugins,
    List<PluginGroup>? pluginGroups,
  }) async {
    if (_isInitialized) return;

    // Register plugins
    if (plugins != null) {
      for (final plugin in plugins) {
        _pluginRegistry.registerPlugin(plugin);
      }
    }

    // Register plugin groups
    if (pluginGroups != null) {
      for (final group in pluginGroups) {
        _pluginRegistry.registerGroup(group);
      }
    }

    // Initialize all plugins
    for (final plugin in _pluginRegistry.enabledPlugins) {
      plugin.initialize();
    }

    if (enableCrashMonitoring) {
      await initializeCrashMonitoring();
    }

    if (enableAnrMonitoring && Platform.isAndroid) {
      await initializeAnrMonitoring();
    }

    _debugOverlayEnabled = enableDebugOverlay;
    _isInitialized = true;
  }

  /// Get platform version
  static Future<String?> getPlatformVersion() {
    return LumioPlatform.instance.getPlatformVersion();
  }

  /// Log API response with URL, status code, and response body
  static Future<void> logApiResponse(String url, int statusCode, String body) async {
    try {
      await LumioPlatform.instance.logApiResponse(url, statusCode, body);
    } catch (e) {
      debugPrint('AppPulse: Failed to log API response: $e');
    }
  }

  /// Log network call with method, URL, and duration
  static Future<void> logNetworkCall(String method, String url, int durationMs) async {
    try {
      await LumioPlatform.instance.logNetworkCall(method, url, durationMs);
    } catch (e) {
      debugPrint('AppPulse: Failed to log network call: $e');
    }
  }

  /// Log crash with error message and stack trace
  static Future<void> logCrash(String error, String stackTrace) async {
    try {
      await LumioPlatform.instance.logCrash(error, stackTrace);
    } catch (e) {
      debugPrint('AppPulse: Failed to log crash: $e');
    }
  }

  /// Log ANR (Application Not Responding) event
  static Future<void> logAnr(String message) async {
    try {
      await LumioPlatform.instance.logAnr(message);
    } catch (e) {
      debugPrint('AppPulse: Failed to log ANR: $e');
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
      debugPrint('AppPulse: Failed to initialize crash monitoring: $e');
    }
  }

  /// Initialize ANR monitoring (Android only)
  static Future<void> initializeAnrMonitoring() async {
    if (_anrMonitoringEnabled || !Platform.isAndroid) return;

    try {
      await LumioPlatform.instance.initializeAnrMonitoring();
      _anrMonitoringEnabled = true;
    } catch (e) {
      debugPrint('AppPulse: Failed to initialize ANR monitoring: $e');
    }
  }

  /// Check if AppPulse is initialized
  static bool get isInitialized => _isInitialized;

  /// Check if crash monitoring is enabled
  static bool get isCrashMonitoringEnabled => _crashMonitoringEnabled;

  /// Check if ANR monitoring is enabled
  static bool get isAnrMonitoringEnabled => _anrMonitoringEnabled;
  
  /// Check if debug overlay is enabled
  static bool get isDebugOverlayEnabled => _debugOverlayEnabled;
  
  /// Get plugin registry
  static PluginRegistry get pluginRegistry => _pluginRegistry;
  
  /// Get all plugins
  static List<Plugin> get allPlugins => _pluginRegistry.allPlugins;
  
  /// Get enabled plugins
  static List<Plugin> get enabledPlugins => _pluginRegistry.enabledPlugins;
  
  /// Get plugin by name
  static Plugin? getPlugin(String name) => _pluginRegistry.getPlugin(name);
  
  /// Show debug overlay
  static void showDebugOverlay() {
    if (_debugOverlayEnabled) {
      // Implementation will be added
    }
  }
  
  /// Hide debug overlay
  static void hideDebugOverlay() {
    if (_debugOverlayEnabled) {
      // Implementation will be added
    }
  }
  
  /// Toggle debug overlay
  static void toggleDebugOverlay() {
    if (_debugOverlayEnabled) {
      // Implementation will be added
    }
  }
  
  /// Export all plugin data
  static Future<Map<String, dynamic>> exportAllData() async {
    return await _pluginRegistry.exportAllData();
  }
  
  /// Dispose all plugins
  static void dispose() {
    for (final plugin in _pluginRegistry.allPlugins) {
      plugin.dispose();
    }
    _pluginRegistry.clear();
    _isInitialized = false;
  }
}
