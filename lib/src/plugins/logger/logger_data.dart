/// Represents a log entry in the application
class LogEntry {
  final String id;
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String tag;
  final Map<String, dynamic> data;
  final String? stackTrace;
  final String? userId;
  final String? sessionId;

  LogEntry({
    required this.id,
    required this.timestamp,
    required this.level,
    required this.message,
    required this.tag,
    this.data = const {},
    this.stackTrace,
    this.userId,
    this.sessionId,
  });

  /// Create a copy with updated fields
  LogEntry copyWith({
    String? id,
    DateTime? timestamp,
    LogLevel? level,
    String? message,
    String? tag,
    Map<String, dynamic>? data,
    String? stackTrace,
    String? userId,
    String? sessionId,
  }) {
    return LogEntry(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      level: level ?? this.level,
      message: message ?? this.message,
      tag: tag ?? this.tag,
      data: data ?? this.data,
      stackTrace: stackTrace ?? this.stackTrace,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  /// Get the emoji icon for this log level
  String get icon {
    switch (level) {
      case LogLevel.verbose:
        return '💬';
      case LogLevel.debug:
        return '🐛';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.fatal:
        return '💥';
    }
  }

  /// Get formatted message with data if present
  String get formattedMessage {
    if (data.isEmpty) return message;
    
    final buffer = StringBuffer(message);
    buffer.writeln();
    buffer.writeln('Data:');
    data.forEach((key, value) {
      buffer.writeln('  $key: $value');
    });
    
    return buffer.toString().trim();
  }

  /// Convert to JSON for export
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'level': level.name,
      'message': message,
      'tag': tag,
      'data': data,
      'stackTrace': stackTrace,
      'userId': userId,
      'sessionId': sessionId,
    };
  }

  /// Create from JSON
  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      level: LogLevel.values.firstWhere((l) => l.name == json['level']),
      message: json['message'],
      tag: json['tag'],
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      stackTrace: json['stackTrace'],
      userId: json['userId'],
      sessionId: json['sessionId'],
    );
  }
}

/// Log levels in order of severity
enum LogLevel {
  verbose,  // Detailed information for debugging
  debug,    // Debug information
  info,     // General information
  warning,  // Warning messages
  error,    // Error messages
  fatal,    // Fatal errors that cause app crashes
}

/// Extension to get color and priority for log levels
extension LogLevelExtension on LogLevel {
  /// Get the color associated with this log level
  int get color {
    switch (this) {
      case LogLevel.verbose:
        return 0xFF9E9E9E; // Grey
      case LogLevel.debug:
        return 0xFF2196F3; // Blue
      case LogLevel.info:
        return 0xFF4CAF50; // Green
      case LogLevel.warning:
        return 0xFFFF9800; // Orange
      case LogLevel.error:
        return 0xFFF44336; // Red
      case LogLevel.fatal:
        return 0xFF9C27B0; // Purple
    }
  }

  /// Get the priority/severity level (higher = more severe)
  int get priority {
    switch (this) {
      case LogLevel.verbose:
        return 0;
      case LogLevel.debug:
        return 1;
      case LogLevel.info:
        return 2;
      case LogLevel.warning:
        return 3;
      case LogLevel.error:
        return 4;
      case LogLevel.fatal:
        return 5;
    }
  }

  /// Check if this level is at least as severe as the given level
  bool isAtLeast(LogLevel level) {
    return priority >= level.priority;
  }
}

/// Statistics about log entries
class LogStats {
  final int totalLogs;
  final int verboseLogs;
  final int debugLogs;
  final int infoLogs;
  final int warningLogs;
  final int errorLogs;
  final int fatalLogs;
  final Map<String, int> tagBreakdown;
  final DateTime? firstLogTime;
  final DateTime? lastLogTime;

  LogStats({
    required this.totalLogs,
    required this.verboseLogs,
    required this.debugLogs,
    required this.infoLogs,
    required this.warningLogs,
    required this.errorLogs,
    required this.fatalLogs,
    required this.tagBreakdown,
    this.firstLogTime,
    this.lastLogTime,
  });

  /// Get the most active tag
  String get mostActiveTag {
    if (tagBreakdown.isEmpty) return 'N/A';
    
    var maxCount = 0;
    var mostActive = 'N/A';
    
    tagBreakdown.forEach((tag, count) {
      if (count > maxCount) {
        maxCount = count;
        mostActive = tag;
      }
    });
    
    return mostActive;
  }

  /// Get error rate percentage
  double get errorRate {
    if (totalLogs == 0) return 0.0;
    return ((errorLogs + fatalLogs) / totalLogs) * 100;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'totalLogs': totalLogs,
      'verboseLogs': verboseLogs,
      'debugLogs': debugLogs,
      'infoLogs': infoLogs,
      'warningLogs': warningLogs,
      'errorLogs': errorLogs,
      'fatalLogs': fatalLogs,
      'tagBreakdown': tagBreakdown,
      'firstLogTime': firstLogTime?.toIso8601String(),
      'lastLogTime': lastLogTime?.toIso8601String(),
      'mostActiveTag': mostActiveTag,
      'errorRate': errorRate,
    };
  }
}

/// Filter criteria for log entries
class LogFilter {
  final LogLevel? minLevel;
  final LogLevel? maxLevel;
  final String? tag;
  final String? searchQuery;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? userId;
  final String? sessionId;
  final bool includeStackTraces;

  LogFilter({
    this.minLevel,
    this.maxLevel,
    this.tag,
    this.searchQuery,
    this.startTime,
    this.endTime,
    this.userId,
    this.sessionId,
    this.includeStackTraces = true,
  });

  /// Create a copy with updated fields
  LogFilter copyWith({
    LogLevel? minLevel,
    LogLevel? maxLevel,
    String? tag,
    String? searchQuery,
    DateTime? startTime,
    DateTime? endTime,
    String? userId,
    String? sessionId,
    bool? includeStackTraces,
  }) {
    return LogFilter(
      minLevel: minLevel ?? this.minLevel,
      maxLevel: maxLevel ?? this.maxLevel,
      tag: tag ?? this.tag,
      searchQuery: searchQuery ?? this.searchQuery,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      includeStackTraces: includeStackTraces ?? this.includeStackTraces,
    );
  }

  /// Check if this filter has any criteria set
  bool get hasFilters {
    return minLevel != null ||
           maxLevel != null ||
           tag != null ||
           (searchQuery != null && searchQuery!.isNotEmpty) ||
           startTime != null ||
           endTime != null ||
           userId != null ||
           sessionId != null ||
           !includeStackTraces;
  }

  /// Check if a log entry matches this filter
  bool matches(LogEntry entry) {
    // Level filters
    if (minLevel != null && !entry.level.isAtLeast(minLevel!)) {
      return false;
    }
    if (maxLevel != null && entry.level.priority > maxLevel!.priority) {
      return false;
    }

    // Tag filter
    if (tag != null && entry.tag != tag) {
      return false;
    }

    // Search query filter
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase();
      if (!entry.message.toLowerCase().contains(query) &&
          !entry.tag.toLowerCase().contains(query) &&
          !(entry.stackTrace?.toLowerCase().contains(query) ?? false)) {
        return false;
      }
    }

    // Time range filters
    if (startTime != null && entry.timestamp.isBefore(startTime!)) {
      return false;
    }
    if (endTime != null && entry.timestamp.isAfter(endTime!)) {
      return false;
    }

    // User ID filter
    if (userId != null && entry.userId != userId) {
      return false;
    }

    // Session ID filter
    if (sessionId != null && entry.sessionId != sessionId) {
      return false;
    }

    // Stack trace filter
    if (!includeStackTraces && entry.stackTrace != null) {
      return false;
    }

    return true;
  }
}
