import 'package:flutter/material.dart';
import '../plugin_base.dart';
import 'crash_manager.dart';
import 'crash_screen.dart';

/// Crash Plugin for monitoring crashes, exceptions, and ANRs
/// Similar to Android Pluto's crash plugin
class CrashPlugin extends Plugin {
  final CrashManager _crashManager = CrashManager();
  final CrashPluginConfiguration _config;
  
  CrashPlugin({
    CrashPluginConfiguration? configuration,
  }) : _config = configuration ?? const CrashPluginConfiguration();
  
  @override
  String get name => 'Crash Plugin';
  
  @override
  String get description => 'Track crashes, exceptions, and ANR events with detailed stack traces';
  
  @override
  String get version => '1.0.0';
  
  @override
  IconData? get icon => Icons.bug_report;
  
  @override
  Color? get color => Colors.red;
  
  @override
  bool get isEnabled => _config.enabled;
  
  @override
  PluginConfiguration? get configuration => _config;
  
  @override
  PluginStatistics get statistics {
    final crashes = _crashManager.getAllCrashes();
    final errors = crashes.where((c) => c.type == CrashType.error).length;
    final warnings = crashes.where((c) => c.type == CrashType.warning).length;
    
    return PluginStatistics(
      totalItems: crashes.length,
      errorCount: errors,
      warningCount: warnings,
      lastActivity: crashes.isNotEmpty ? crashes.last.timestamp : DateTime.now(),
      uptime: DateTime.now().difference(_crashManager.startTime),
    );
  }
  
  @override
  void initialize() {
    if (_config.enableNativeCrashCapture) {
      _crashManager.enableNativeCrashCapture();
    }
    
    if (_config.enableANRDetection) {
      _crashManager.enableANRDetection();
    }
    
    if (_config.enableFlutterCrashCapture) {
      _crashManager.enableFlutterCrashCapture();
    }
    
    _crashManager.setMaxStoredCrashes(_config.maxStoredCrashes);
    
    // Start monitoring
    _crashManager.start();
  }
  
  @override
  void dispose() {
    _crashManager.stop();
  }
  
  @override
  Widget buildDebugScreen() {
    return CrashScreen(
      crashManager: _crashManager,
      configuration: _config,
    );
  }
  
  @override
  Future<Map<String, dynamic>> exportData() async {
    final baseData = await super.exportData();
    final crashes = _crashManager.getAllCrashes();
    
    return {
      ...baseData,
      'crashes': crashes.map((c) => c.toJson()).toList(),
      'statistics': {
        'totalCrashes': crashes.length,
        'flutterCrashes': crashes.where((c) => c.type == CrashType.flutter).length,
        'nativeCrashes': crashes.where((c) => c.type == CrashType.native).length,
        'anrEvents': crashes.where((c) => c.type == CrashType.anr).length,
        'fatalCrashes': crashes.where((c) => c.severity == CrashSeverity.fatal).length,
      },
    };
  }
  
  /// Get crash manager instance
  CrashManager get crashManager => _crashManager;
  
  /// Clear all stored crashes
  void clearCrashes() {
    _crashManager.clearAllCrashes();
  }
  
  /// Get crash by ID
  CrashData? getCrash(String id) {
    return _crashManager.getCrash(id);
  }
  
  /// Get all crashes
  List<CrashData> getAllCrashes() {
    return _crashManager.getAllCrashes();
  }
  
  /// Get crashes by type
  List<CrashData> getCrashesByType(CrashType type) {
    return _crashManager.getAllCrashes()
        .where((c) => c.type == type)
        .toList();
  }
  
  /// Get crashes by severity
  List<CrashData> getCrashesBySeverity(CrashSeverity severity) {
    return _crashManager.getAllCrashes()
        .where((c) => c.severity == severity)
        .toList();
  }
  
  /// Get crashes by error message pattern
  List<CrashData> getCrashesByErrorPattern(String pattern) {
    return _crashManager.getAllCrashes()
        .where((c) => c.error.contains(pattern))
        .toList();
  }
  
  /// Manually log a crash
  void logCrash(String error, String stackTrace, {
    CrashType type = CrashType.flutter,
    CrashSeverity severity = CrashSeverity.error,
    Map<String, dynamic>? metadata,
  }) {
    _crashManager.logCrash(
      error: error,
      stackTrace: stackTrace,
      type: type,
      severity: severity,
      metadata: metadata,
    );
  }
  
  /// Manually log an ANR event
  void logANR(String message, {Map<String, dynamic>? metadata}) {
    _crashManager.logANR(message, metadata: metadata);
  }
}

/// Crash plugin configuration
class CrashPluginConfiguration extends PluginConfiguration {
  final bool enableNativeCrashCapture;
  final bool enableANRDetection;
  final bool enableFlutterCrashCapture;
  final int maxStoredCrashes;
  final bool enabled;
  final Duration anrThreshold;
  final bool enableCrashReports;
  
  const CrashPluginConfiguration({
    super.enableNotifications = true,
    super.enableExport = true,
    super.maxStoredItems = 100,
    super.dataRetentionPeriod = const Duration(days: 30),
    this.enableNativeCrashCapture = true,
    this.enableANRDetection = true,
    this.enableFlutterCrashCapture = true,
    this.maxStoredCrashes = 100,
    this.enabled = true,
    this.anrThreshold = const Duration(seconds: 5),
    this.enableCrashReports = true,
  });
  
  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'enableNativeCrashCapture': enableNativeCrashCapture,
      'enableANRDetection': enableANRDetection,
      'enableFlutterCrashCapture': enableFlutterCrashCapture,
      'maxStoredCrashes': maxStoredCrashes,
      'enabled': enabled,
      'anrThreshold': anrThreshold.inSeconds,
      'enableCrashReports': enableCrashReports,
    };
  }
}
