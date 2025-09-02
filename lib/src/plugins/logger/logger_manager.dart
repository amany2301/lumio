import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'logger_data.dart';

/// Manages log entries and provides APIs for logging and monitoring
class LoggerManager {
  static final LoggerManager _instance = LoggerManager._internal();
  factory LoggerManager() => _instance;
  LoggerManager._internal();

  final List<LogEntry> _logs = [];
  final StreamController<LogEntry> _logController = StreamController<LogEntry>.broadcast();
  final StreamController<LogStats> _statsController = StreamController<LogStats>.broadcast();
  
  int _maxStoredLogs = 10000;
  bool _isEnabled = true;
  LogLevel _minLevel = LogLevel.verbose;
  String? _currentUserId;
  String? _currentSessionId;

  /// Stream of log entries
  Stream<LogEntry> get logStream => _logController.stream;
  
  /// Stream of log statistics
  Stream<LogStats> get statsStream => _statsController.stream;

  /// Get all log entries
  List<LogEntry> get allLogs => List.unmodifiable(_logs);

  /// Get current session ID
  String? get currentSessionId => _currentSessionId;

  /// Get current user ID
  String? get currentUserId => _currentUserId;

  /// Get log statistics
  LogStats get stats {
    final total = _logs.length;
    final verbose = _logs.where((l) => l.level == LogLevel.verbose).length;
    final debug = _logs.where((l) => l.level == LogLevel.debug).length;
    final info = _logs.where((l) => l.level == LogLevel.info).length;
    final warning = _logs.where((l) => l.level == LogLevel.warning).length;
    final error = _logs.where((l) => l.level == LogLevel.error).length;
    final fatal = _logs.where((l) => l.level == LogLevel.fatal).length;

    // Tag breakdown
    final tagBreakdown = <String, int>{};
    for (final log in _logs) {
      tagBreakdown[log.tag] = (tagBreakdown[log.tag] ?? 0) + 1;
    }

    final firstLog = _logs.isNotEmpty ? _logs.last.timestamp : null;
    final lastLog = _logs.isNotEmpty ? _logs.first.timestamp : null;

    return LogStats(
      totalLogs: total,
      verboseLogs: verbose,
      debugLogs: debug,
      infoLogs: info,
      warningLogs: warning,
      errorLogs: error,
      fatalLogs: fatal,
      tagBreakdown: tagBreakdown,
      firstLogTime: firstLog,
      lastLogTime: lastLog,
    );
  }

  /// Initialize the logger
  void initialize({
    String? userId,
    String? sessionId,
    LogLevel minLevel = LogLevel.verbose,
    int maxStoredLogs = 10000,
  }) {
    _currentUserId = userId;
    _currentSessionId = sessionId ?? _generateSessionId();
    _minLevel = minLevel;
    _maxStoredLogs = maxStoredLogs;
    
    log(
      level: LogLevel.info,
      tag: 'LoggerManager',
      message: 'Logger initialized',
      data: {
        'userId': _currentUserId,
        'sessionId': _currentSessionId,
        'minLevel': minLevel.name,
        'maxStoredLogs': maxStoredLogs,
      },
    );
  }

  /// Enable or disable logging
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    if (enabled) {
      log(
        level: LogLevel.info,
        tag: 'LoggerManager',
        message: 'Logging enabled',
      );
    }
  }

  /// Set minimum log level
  void setMinLevel(LogLevel level) {
    _minLevel = level;
    log(
      level: LogLevel.info,
      tag: 'LoggerManager',
      message: 'Minimum log level set to ${level.name}',
    );
  }

  /// Set current user ID
  void setUserId(String? userId) {
    _currentUserId = userId;
    log(
      level: LogLevel.info,
      tag: 'LoggerManager',
      message: 'User ID updated',
      data: {'userId': userId},
    );
  }

  /// Start a new session
  void startNewSession() {
    _currentSessionId = _generateSessionId();
    log(
      level: LogLevel.info,
      tag: 'LoggerManager',
      message: 'New session started',
      data: {'sessionId': _currentSessionId},
    );
  }

  /// Set maximum number of stored logs
  void setMaxStoredLogs(int maxLogs) {
    _maxStoredLogs = maxLogs;
    _trimLogsIfNeeded();
    log(
      level: LogLevel.info,
      tag: 'LoggerManager',
      message: 'Max stored logs set to $maxLogs',
    );
  }

  /// Log a message
  String log({
    required LogLevel level,
    required String tag,
    required String message,
    Map<String, dynamic> data = const {},
    String? stackTrace,
  }) {
    if (!_isEnabled || !level.isAtLeast(_minLevel)) return '';

    final id = _generateId();
    final entry = LogEntry(
      id: id,
      timestamp: DateTime.now(),
      level: level,
      message: message,
      tag: tag,
      data: Map<String, dynamic>.from(data),
      stackTrace: stackTrace,
      userId: _currentUserId,
      sessionId: _currentSessionId,
    );

    _logs.insert(0, entry);
    _trimLogsIfNeeded();
    
    _logController.add(entry);
    _statsController.add(stats);

    // Print to console in debug mode
    if (kDebugMode) {
      debugPrint('[${entry.level.name.toUpperCase()}] [${entry.tag}] ${entry.message}');
      if (entry.data.isNotEmpty) {
        debugPrint('  Data: ${entry.data}');
      }
      if (entry.stackTrace != null) {
        debugPrint('  Stack trace:\n${entry.stackTrace}');
      }
    }

    return id;
  }

  /// Log verbose message
  String verbose(String tag, String message, {Map<String, dynamic> data = const {}}) {
    return log(level: LogLevel.verbose, tag: tag, message: message, data: data);
  }

  /// Log debug message
  String debug(String tag, String message, {Map<String, dynamic> data = const {}}) {
    return log(level: LogLevel.debug, tag: tag, message: message, data: data);
  }

  /// Log info message
  String info(String tag, String message, {Map<String, dynamic> data = const {}}) {
    return log(level: LogLevel.info, tag: tag, message: message, data: data);
  }

  /// Log warning message
  String warning(String tag, String message, {Map<String, dynamic> data = const {}}) {
    return log(level: LogLevel.warning, tag: tag, message: message, data: data);
  }

  /// Log error message
  String error(String tag, String message, {Map<String, dynamic> data = const {}, String? stackTrace}) {
    return log(level: LogLevel.error, tag: tag, message: message, data: data, stackTrace: stackTrace);
  }

  /// Log fatal message
  String fatal(String tag, String message, {Map<String, dynamic> data = const {}, String? stackTrace}) {
    return log(level: LogLevel.fatal, tag: tag, message: message, data: data, stackTrace: stackTrace);
  }

  /// Filter logs based on criteria
  List<LogEntry> filterLogs(LogFilter filter) {
    return _logs.where((log) => filter.matches(log)).toList();
  }

  /// Search logs by text
  List<LogEntry> searchLogs(String query) {
    if (query.isEmpty) return _logs;

    final lowerQuery = query.toLowerCase();
    return _logs.where((log) {
      return log.message.toLowerCase().contains(lowerQuery) ||
             log.tag.toLowerCase().contains(lowerQuery) ||
             (log.stackTrace?.toLowerCase().contains(lowerQuery) ?? false) ||
             log.data.toString().toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Get logs by level
  List<LogEntry> getLogsByLevel(LogLevel level) {
    return _logs.where((log) => log.level == level).toList();
  }

  /// Get logs by tag
  List<LogEntry> getLogsByTag(String tag) {
    return _logs.where((log) => log.tag == tag).toList();
  }

  /// Get logs in time range
  List<LogEntry> getLogsInTimeRange({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    return _logs.where((log) {
      return log.timestamp.isAfter(startTime) && log.timestamp.isBefore(endTime);
    }).toList();
  }

  /// Get unique tags
  List<String> getUniqueTags() {
    final tags = <String>{};
    for (final log in _logs) {
      tags.add(log.tag);
    }
    return tags.toList()..sort();
  }

  /// Get logs by session
  List<LogEntry> getLogsBySession(String sessionId) {
    return _logs.where((log) => log.sessionId == sessionId).toList();
  }

  /// Get logs by user
  List<LogEntry> getLogsByUser(String userId) {
    return _logs.where((log) => log.userId == userId).toList();
  }

  /// Get a specific log by ID
  LogEntry? getLog(String id) {
    try {
      return _logs.firstWhere((log) => log.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Clear all logs
  void clearAll() {
    _logs.clear();
    _statsController.add(stats);
    log(
      level: LogLevel.info,
      tag: 'LoggerManager',
      message: 'All logs cleared',
    );
  }

  /// Clear logs older than specified duration
  void clearOldLogs(Duration maxAge) {
    final cutoff = DateTime.now().subtract(maxAge);
    final initialCount = _logs.length;
    _logs.removeWhere((log) => log.timestamp.isBefore(cutoff));
    final removedCount = initialCount - _logs.length;
    
    _statsController.add(stats);
    
    if (removedCount > 0) {
      log(
        level: LogLevel.info,
        tag: 'LoggerManager',
        message: 'Cleared $removedCount old logs',
      );
    }
  }

  /// Clear logs by level
  void clearLogsByLevel(LogLevel level) {
    final initialCount = _logs.length;
    _logs.removeWhere((log) => log.level == level);
    final removedCount = initialCount - _logs.length;
    
    _statsController.add(stats);
    
    if (removedCount > 0) {
      log(
        level: LogLevel.info,
        tag: 'LoggerManager',
        message: 'Cleared $removedCount ${level.name} logs',
      );
    }
  }

  /// Clear logs by tag
  void clearLogsByTag(String tag) {
    final initialCount = _logs.length;
    _logs.removeWhere((log) => log.tag == tag);
    final removedCount = initialCount - _logs.length;
    
    _statsController.add(stats);
    
    if (removedCount > 0) {
      log(
        level: LogLevel.info,
        tag: 'LoggerManager',
        message: 'Cleared $removedCount logs with tag "$tag"',
      );
    }
  }

  /// Export logs as JSON
  Map<String, dynamic> exportAsJson({
    LogFilter? filter,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    List<LogEntry> logsToExport = _logs;
    
    if (filter != null) {
      logsToExport = filterLogs(filter);
    } else if (startTime != null || endTime != null) {
      logsToExport = _logs.where((log) {
        if (startTime != null && log.timestamp.isBefore(startTime)) return false;
        if (endTime != null && log.timestamp.isAfter(endTime)) return false;
        return true;
      }).toList();
    }

    return {
      'timestamp': DateTime.now().toIso8601String(),
      'totalLogs': logsToExport.length,
      'stats': stats.toJson(),
      'logs': logsToExport.map((log) => log.toJson()).toList(),
      'sessionId': _currentSessionId,
      'userId': _currentUserId,
      'minLevel': _minLevel.name,
      'maxStoredLogs': _maxStoredLogs,
    };
  }

  /// Generate a unique ID
  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    return '${timestamp}_$random';
  }

  /// Generate a unique session ID
  String _generateSessionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    return 'session_${timestamp}_$random';
  }

  /// Trim logs if we exceed the maximum
  void _trimLogsIfNeeded() {
    if (_logs.length > _maxStoredLogs) {
      final removedCount = _logs.length - _maxStoredLogs;
      _logs.removeRange(_maxStoredLogs, _logs.length);
      
      // Don't log this if we're initializing (to avoid infinite loop)
      if (_logs.isNotEmpty) {
        log(
          level: LogLevel.debug,
          tag: 'LoggerManager',
          message: 'Trimmed $removedCount old logs',
        );
      }
    }
  }

  /// Dispose resources
  void dispose() {
    _logController.close();
    _statsController.close();
  }
}
