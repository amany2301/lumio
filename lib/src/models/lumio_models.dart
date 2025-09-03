import 'dart:convert';

/// Optimized base class for all Lumio logs
abstract class LumioLog {
  final DateTime timestamp;
  
  const LumioLog({required this.timestamp});
  
  Map<String, dynamic> toJson();
  
  /// Optimized JSON serialization
  String toJsonString() => jsonEncode(toJson());
  
  /// Get formatted timestamp
  String get formattedTimestamp => 
      '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} '
      '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
}

/// Optimized network call log
class NetworkCallLog extends LumioLog {
  final String method;
  final String url;
  final int durationMs;
  final String? error;
  final Map<String, String>? headers;
  final String? requestBody;
  final int? statusCode;

  const NetworkCallLog({
    required this.method,
    required this.url,
    required this.durationMs,
    required super.timestamp,
    this.error,
    this.headers,
    this.requestBody,
    this.statusCode,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'url': url,
      'durationMs': durationMs,
      'timestamp': timestamp.toIso8601String(),
      'error': error,
      'headers': headers,
      'requestBody': requestBody,
      'statusCode': statusCode,
    };
  }

  factory NetworkCallLog.fromJson(Map<String, dynamic> json) {
    return NetworkCallLog(
      method: json['method'] as String,
      url: json['url'] as String,
      durationMs: json['durationMs'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      error: json['error'] as String?,
      headers: json['headers'] != null 
          ? Map<String, String>.from(json['headers'] as Map)
          : null,
      requestBody: json['requestBody'] as String?,
      statusCode: json['statusCode'] as int?,
    );
  }

  /// Get formatted duration
  String get formattedDuration {
    if (durationMs < 1000) return '${durationMs}ms';
    return '${(durationMs / 1000).toStringAsFixed(2)}s';
  }

  /// Get status color
  String get statusColor {
    if (error != null) return 'red';
    if (statusCode == null) return 'orange';
    if (statusCode! >= 200 && statusCode! < 300) return 'green';
    if (statusCode! >= 400) return 'red';
    return 'orange';
  }
}

/// Optimized API response log
class ApiResponseLog extends LumioLog {
  final String url;
  final int statusCode;
  final String body;
  final Map<String, String>? headers;
  final int? responseSize;

  const ApiResponseLog({
    required this.url,
    required this.statusCode,
    required this.body,
    required super.timestamp,
    this.headers,
    this.responseSize,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'statusCode': statusCode,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'headers': headers,
      'responseSize': responseSize ?? body.length,
    };
  }

  factory ApiResponseLog.fromJson(Map<String, dynamic> json) {
    return ApiResponseLog(
      url: json['url'] as String,
      statusCode: json['statusCode'] as int,
      body: json['body'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      headers: json['headers'] != null 
          ? Map<String, String>.from(json['headers'] as Map)
          : null,
      responseSize: json['responseSize'] as int?,
    );
  }

  /// Get formatted response size
  String get formattedSize {
    final size = responseSize ?? body.length;
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  /// Get status color
  String get statusColor {
    if (statusCode >= 200 && statusCode < 300) return 'green';
    if (statusCode >= 400) return 'red';
    return 'orange';
  }

  /// Get truncated body for display
  String get truncatedBody {
    const maxLength = 500;
    if (body.length <= maxLength) return body;
    return '${body.substring(0, maxLength)}...';
  }
}

/// Optimized crash log
class CrashLog extends LumioLog {
  final String error;
  final String stackTrace;
  final String? type;
  final Map<String, dynamic>? metadata;

  const CrashLog({
    required this.error,
    required this.stackTrace,
    required super.timestamp,
    this.type,
    this.metadata,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'stackTrace': stackTrace,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'metadata': metadata,
    };
  }

  factory CrashLog.fromJson(Map<String, dynamic> json) {
    return CrashLog(
      error: json['error'] as String,
      stackTrace: json['stackTrace'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: json['type'] as String?,
      metadata: json['metadata'] != null 
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
    );
  }

  /// Get error type
  String get errorType {
    if (type != null) return type!;
    if (error.contains('Exception')) return 'Exception';
    if (error.contains('Error')) return 'Error';
    return 'Unknown';
  }

  /// Get truncated stack trace
  String get truncatedStackTrace {
    const maxLines = 10;
    final lines = stackTrace.split('\n');
    if (lines.length <= maxLines) return stackTrace;
    return lines.take(maxLines).join('\n') + '\n...';
  }
}

/// Optimized ANR log
class AnrLog extends LumioLog {
  final String message;
  final int? durationMs;
  final String? threadInfo;
  final Map<String, dynamic>? metadata;

  const AnrLog({
    required this.message,
    required super.timestamp,
    this.durationMs,
    this.threadInfo,
    this.metadata,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'durationMs': durationMs,
      'threadInfo': threadInfo,
      'metadata': metadata,
    };
  }

  factory AnrLog.fromJson(Map<String, dynamic> json) {
    return AnrLog(
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      durationMs: json['durationMs'] as int?,
      threadInfo: json['threadInfo'] as String?,
      metadata: json['metadata'] != null 
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
    );
  }

  /// Get formatted duration
  String get formattedDuration {
    if (durationMs == null) return 'Unknown';
    if (durationMs! < 1000) return '${durationMs}ms';
    return '${(durationMs! / 1000).toStringAsFixed(2)}s';
  }
}

/// Optimized log summary for performance
class LogSummary {
  final int totalLogs;
  final int networkCalls;
  final int apiResponses;
  final int crashes;
  final int anrs;
  final DateTime? lastLogTime;
  final Map<String, int> statusCodes;
  final Map<String, int> errorTypes;

  const LogSummary({
    required this.totalLogs,
    required this.networkCalls,
    required this.apiResponses,
    required this.crashes,
    required this.anrs,
    this.lastLogTime,
    required this.statusCodes,
    required this.errorTypes,
  });

  /// Create summary from logs
  factory LogSummary.fromLogs({
    required List<NetworkCallLog> networkCalls,
    required List<ApiResponseLog> apiResponses,
    required List<CrashLog> crashes,
    required List<AnrLog> anrs,
  }) {
    final allLogs = [
      ...networkCalls,
      ...apiResponses,
      ...crashes,
      ...anrs,
    ];

    final statusCodes = <String, int>{};
    for (final response in apiResponses) {
      final status = response.statusCode.toString();
      statusCodes[status] = (statusCodes[status] ?? 0) + 1;
    }

    final errorTypes = <String, int>{};
    for (final crash in crashes) {
      final type = crash.errorType;
      errorTypes[type] = (errorTypes[type] ?? 0) + 1;
    }

    return LogSummary(
      totalLogs: allLogs.length,
      networkCalls: networkCalls.length,
      apiResponses: apiResponses.length,
      crashes: crashes.length,
      anrs: anrs.length,
      lastLogTime: allLogs.isNotEmpty 
          ? allLogs.map((e) => e.timestamp).reduce((a, b) => a.isAfter(b) ? a : b)
          : null,
      statusCodes: statusCodes,
      errorTypes: errorTypes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalLogs': totalLogs,
      'networkCalls': networkCalls,
      'apiResponses': apiResponses,
      'crashes': crashes,
      'anrs': anrs,
      'lastLogTime': lastLogTime?.toIso8601String(),
      'statusCodes': statusCodes,
      'errorTypes': errorTypes,
    };
  }
}
