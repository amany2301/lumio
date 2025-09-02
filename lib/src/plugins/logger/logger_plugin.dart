import 'package:flutter/material.dart';
import '../plugin_base.dart';
import 'logger_manager.dart';
import 'logger_screen.dart';

/// Logger Plugin for advanced logging with filtering and real-time monitoring
/// Similar to Android Pluto's logger plugin
class LoggerPlugin extends Plugin {
  final LoggerManager _loggerManager = LoggerManager();
  final LoggerPluginConfiguration _config;
  
  LoggerPlugin({
    LoggerPluginConfiguration? configuration,
  }) : _config = configuration ?? const LoggerPluginConfiguration();
  
  @override
  String get name => 'Logger Plugin';
  
  @override
  String get description => 'Advanced logging with filtering, search, and real-time monitoring';
  
  @override
  String get version => '1.0.0';
  
  @override
  IconData? get icon => Icons.list_alt;
  
  @override
  Color? get color => Colors.purple;
  
  @override
  bool get isEnabled => _config.enabled;
  
  @override
  PluginConfiguration? get configuration => _config;
  
  @override
  PluginStatistics get statistics {
    final logs = _loggerManager.allLogs;
    final errors = logs.where((l) => l.level == LogLevel.error || l.level == LogLevel.fatal).length;
    final warnings = logs.where((l) => l.level == LogLevel.warning).length;
    
    return PluginStatistics(
      totalItems: logs.length,
      errorCount: errors,
      warningCount: warnings,
      lastActivity: logs.isNotEmpty ? logs.last.timestamp : DateTime.now(),
      uptime: DateTime.now().difference(_loggerManager.startTime),
    );
  }
  
  @override
  void initialize() {
    _loggerManager.setMinLevel(_config.minLogLevel);
    _loggerManager.setMaxStoredLogs(_config.maxStoredLogs);
    
    if (_config.enableRealTimeStreaming) {
      _loggerManager.enableRealTimeStreaming();
    }
    
    if (_config.enableSessionTracking) {
      _loggerManager.enableSessionTracking();
    }
    
    if (_config.enableUserTracking) {
      _loggerManager.enableUserTracking();
    }
    
    // Start logging
    _loggerManager.start();
  }
  
  @override
  void dispose() {
    _loggerManager.stop();
  }
  
  @override
  Widget buildDebugScreen() {
    return LoggerScreen(
      loggerManager: _loggerManager,
      configuration: _config,
    );
  }
  
  @override
  Future<Map<String, dynamic>> exportData() async {
    final baseData = await super.exportData();
    final logs = _loggerManager.allLogs;
    
    return {
      ...baseData,
      'logs': logs.map((l) => l.toJson()).toList(),
      'statistics': {
        'totalLogs': logs.length,
        'verboseLogs': logs.where((l) => l.level == LogLevel.verbose).length,
        'debugLogs': logs.where((l) => l.level == LogLevel.debug).length,
        'infoLogs': logs.where((l) => l.level == LogLevel.info).length,
        'warningLogs': logs.where((l) => l.level == LogLevel.warning).length,
        'errorLogs': logs.where((l) => l.level == LogLevel.error).length,
        'fatalLogs': logs.where((l) => l.level == LogLevel.fatal).length,
      },
    };
  }
  
  /// Get logger manager instance
  LoggerManager get loggerManager => _loggerManager;
  
  /// Clear all stored logs
  void clearLogs() {
    _loggerManager.clearAllLogs();
  }
  
  /// Get log by ID
  LogEntry? getLog(String id) {
    return _loggerManager.getLog(id);
  }
  
  /// Get all logs
  List<LogEntry> getAllLogs() {
    return _loggerManager.allLogs;
  }
  
  /// Get logs by level
  List<LogEntry> getLogsByLevel(LogLevel level) {
    return _loggerManager.allLogs
        .where((l) => l.level == level)
        .toList();
  }
  
  /// Get logs by tag
  List<LogEntry> getLogsByTag(String tag) {
    return _loggerManager.allLogs
        .where((l) => l.tag == tag)
        .toList();
  }
  
  /// Get logs by message pattern
  List<LogEntry> getLogsByMessagePattern(String pattern) {
    return _loggerManager.allLogs
        .where((l) => l.message.contains(pattern))
        .toList();
  }
  
  /// Get logs by time range
  List<LogEntry> getLogsByTimeRange(DateTime start, DateTime end) {
    return _loggerManager.allLogs
        .where((l) => l.timestamp.isAfter(start) && l.timestamp.isBefore(end))
        .toList();
  }
  
  /// Manually log a message
  void log(String message, {
    LogLevel level = LogLevel.info,
    String tag = 'Lumio',
    Map<String, dynamic>? data,
    String? stackTrace,
  }) {
    _loggerManager.log(
      message: message,
      level: level,
      tag: tag,
      data: data,
      stackTrace: stackTrace,
    );
  }
  
  /// Log verbose message
  void verbose(String message, {String tag = 'Lumio', Map<String, dynamic>? data}) {
    log(message, level: LogLevel.verbose, tag: tag, data: data);
  }
  
  /// Log debug message
  void debug(String message, {String tag = 'Lumio', Map<String, dynamic>? data}) {
    log(message, level: LogLevel.debug, tag: tag, data: data);
  }
  
  /// Log info message
  void info(String message, {String tag = 'Lumio', Map<String, dynamic>? data}) {
    log(message, level: LogLevel.info, tag: tag, data: data);
  }
  
  /// Log warning message
  void warning(String message, {String tag = 'Lumio', Map<String, dynamic>? data}) {
    log(message, level: LogLevel.warning, tag: tag, data: data);
  }
  
  /// Log error message
  void error(String message, {String tag = 'Lumio', Map<String, dynamic>? data, String? stackTrace}) {
    log(message, level: LogLevel.error, tag: tag, data: data, stackTrace: stackTrace);
  }
  
  /// Log fatal message
  void fatal(String message, {String tag = 'Lumio', Map<String, dynamic>? data, String? stackTrace}) {
    log(message, level: LogLevel.fatal, tag: tag, data: data, stackTrace: stackTrace);
  }
}

/// Logger plugin configuration
class LoggerPluginConfiguration extends PluginConfiguration {
  final LogLevel minLogLevel;
  final int maxStoredLogs;
  final bool enabled;
  final bool enableRealTimeStreaming;
  final bool enableSessionTracking;
  final bool enableUserTracking;
  final bool enableLogExport;
  final Duration logRetentionPeriod;
  
  const LoggerPluginConfiguration({
    super.enableNotifications = true,
    super.enableExport = true,
    super.maxStoredItems = 5000,
    super.dataRetentionPeriod = const Duration(days: 7),
    this.minLogLevel = LogLevel.debug,
    this.maxStoredLogs = 5000,
    this.enabled = true,
    this.enableRealTimeStreaming = true,
    this.enableSessionTracking = true,
    this.enableUserTracking = true,
    this.enableLogExport = true,
    this.logRetentionPeriod = const Duration(days: 7),
  });
  
  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'minLogLevel': minLogLevel.name,
      'maxStoredLogs': maxStoredLogs,
      'enabled': enabled,
      'enableRealTimeStreaming': enableRealTimeStreaming,
      'enableSessionTracking': enableSessionTracking,
      'enableUserTracking': enableUserTracking,
      'enableLogExport': enableLogExport,
      'logRetentionPeriod': logRetentionPeriod.inDays,
    };
  }
}
