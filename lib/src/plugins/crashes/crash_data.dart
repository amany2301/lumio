

/// Represents a crash or exception that occurred in the application
class CrashReport {
  final String id;
  final String title;
  final String message;
  final String stackTrace;
  final DateTime timestamp;
  final CrashType type;
  final CrashSeverity severity;
  final Map<String, dynamic> context;
  final String? userId;
  final Map<String, String> deviceInfo;
  final Map<String, dynamic> customData;

  CrashReport({
    required this.id,
    required this.title,
    required this.message,
    required this.stackTrace,
    required this.timestamp,
    required this.type,
    this.severity = CrashSeverity.error,
    this.context = const {},
    this.userId,
    this.deviceInfo = const {},
    this.customData = const {},
  });

  /// Create a copy with updated fields
  CrashReport copyWith({
    String? id,
    String? title,
    String? message,
    String? stackTrace,
    DateTime? timestamp,
    CrashType? type,
    CrashSeverity? severity,
    Map<String, dynamic>? context,
    String? userId,
    Map<String, String>? deviceInfo,
    Map<String, dynamic>? customData,
  }) {
    return CrashReport(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      stackTrace: stackTrace ?? this.stackTrace,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      context: context ?? this.context,
      userId: userId ?? this.userId,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      customData: customData ?? this.customData,
    );
  }

  /// Get formatted stack trace with line numbers
  String get formattedStackTrace {
    final lines = stackTrace.split('\n');
    final buffer = StringBuffer();
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isNotEmpty) {
        buffer.writeln('${(i + 1).toString().padLeft(3, ' ')}: $line');
      }
    }
    
    return buffer.toString();
  }

  /// Get a short summary of the crash
  String get summary {
    final maxLength = 100;
    if (message.length <= maxLength) return message;
    return '${message.substring(0, maxLength)}...';
  }

  /// Get the crash icon based on type and severity
  String get icon {
    switch (type) {
      case CrashType.flutter:
        return '🐛';
      case CrashType.native:
        return '💥';
      case CrashType.anr:
        return '⏳';
      case CrashType.network:
        return '🌐';
      case CrashType.memory:
        return '💾';
      case CrashType.custom:
        return '⚠️';
    }
  }

  /// Convert to JSON for export
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'stackTrace': stackTrace,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'severity': severity.name,
      'context': context,
      'userId': userId,
      'deviceInfo': deviceInfo,
      'customData': customData,
    };
  }

  /// Create from JSON
  factory CrashReport.fromJson(Map<String, dynamic> json) {
    return CrashReport(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      stackTrace: json['stackTrace'],
      timestamp: DateTime.parse(json['timestamp']),
      type: CrashType.values.firstWhere((t) => t.name == json['type']),
      severity: CrashSeverity.values.firstWhere((s) => s.name == json['severity']),
      context: Map<String, dynamic>.from(json['context'] ?? {}),
      userId: json['userId'],
      deviceInfo: Map<String, String>.from(json['deviceInfo'] ?? {}),
      customData: Map<String, dynamic>.from(json['customData'] ?? {}),
    );
  }
}

/// Types of crashes that can occur
enum CrashType {
  flutter,  // Flutter framework crashes
  native,   // Native platform crashes (Android/iOS)
  anr,      // Application Not Responding (Android)
  network,  // Network-related errors
  memory,   // Memory-related issues
  custom,   // Custom logged errors
}

/// Severity levels for crashes
enum CrashSeverity {
  low,      // Minor issues, app continues
  medium,   // Noticeable issues, some functionality affected
  high,     // Major issues, significant functionality affected
  critical, // App crashes or becomes unusable
  error,    // General errors
}

/// Statistics about crashes and exceptions
class CrashStats {
  final int totalCrashes;
  final int flutterCrashes;
  final int nativeCrashes;
  final int anrEvents;
  final int networkErrors;
  final int memoryIssues;
  final int customErrors;
  final Map<CrashSeverity, int> severityBreakdown;
  final DateTime? lastCrashTime;
  final double crashFreeRate;

  CrashStats({
    required this.totalCrashes,
    required this.flutterCrashes,
    required this.nativeCrashes,
    required this.anrEvents,
    required this.networkErrors,
    required this.memoryIssues,
    required this.customErrors,
    required this.severityBreakdown,
    this.lastCrashTime,
    required this.crashFreeRate,
  });

  /// Get crash rate percentage
  double get crashRate => 100.0 - crashFreeRate;

  /// Get the most common crash type
  CrashType get mostCommonCrashType {
    final counts = {
      CrashType.flutter: flutterCrashes,
      CrashType.native: nativeCrashes,
      CrashType.anr: anrEvents,
      CrashType.network: networkErrors,
      CrashType.memory: memoryIssues,
      CrashType.custom: customErrors,
    };

    var maxCount = 0;
    var mostCommon = CrashType.flutter;

    counts.forEach((type, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommon = type;
      }
    });

    return mostCommon;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'totalCrashes': totalCrashes,
      'flutterCrashes': flutterCrashes,
      'nativeCrashes': nativeCrashes,
      'anrEvents': anrEvents,
      'networkErrors': networkErrors,
      'memoryIssues': memoryIssues,
      'customErrors': customErrors,
      'severityBreakdown': severityBreakdown.map((k, v) => MapEntry(k.name, v)),
      'lastCrashTime': lastCrashTime?.toIso8601String(),
      'crashFreeRate': crashFreeRate,
      'crashRate': crashRate,
      'mostCommonCrashType': mostCommonCrashType.name,
    };
  }
}

/// Breadcrumb for tracking user journey leading to crash
class CrashBreadcrumb {
  final String id;
  final DateTime timestamp;
  final String category;
  final String message;
  final BreadcrumbLevel level;
  final Map<String, dynamic> data;

  CrashBreadcrumb({
    required this.id,
    required this.timestamp,
    required this.category,
    required this.message,
    this.level = BreadcrumbLevel.info,
    this.data = const {},
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'category': category,
      'message': message,
      'level': level.name,
      'data': data,
    };
  }

  /// Create from JSON
  factory CrashBreadcrumb.fromJson(Map<String, dynamic> json) {
    return CrashBreadcrumb(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      category: json['category'],
      message: json['message'],
      level: BreadcrumbLevel.values.firstWhere((l) => l.name == json['level']),
      data: Map<String, dynamic>.from(json['data'] ?? {}),
    );
  }
}

/// Breadcrumb levels
enum BreadcrumbLevel {
  debug,
  info,
  warning,
  error,
  critical,
}
