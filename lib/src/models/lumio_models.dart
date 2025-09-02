/// Data models for Lumio monitoring
library;

/// Represents a network call log entry
class NetworkCallLog {
  final String method;
  final String url;
  final int durationMs;
  final DateTime timestamp;

  const NetworkCallLog({
    required this.method,
    required this.url,
    required this.durationMs,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'url': url,
      'durationMs': durationMs,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Represents an API response log entry
class ApiResponseLog {
  final String url;
  final int statusCode;
  final String body;
  final DateTime timestamp;

  const ApiResponseLog({
    required this.url,
    required this.statusCode,
    required this.body,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'statusCode': statusCode,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Represents a crash log entry
class CrashLog {
  final String error;
  final String stackTrace;
  final DateTime timestamp;

  const CrashLog({
    required this.error,
    required this.stackTrace,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'stackTrace': stackTrace,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Represents an ANR (Application Not Responding) log entry
class AnrLog {
  final String message;
  final DateTime timestamp;

  const AnrLog({
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Configuration for Lumio monitoring
class LumioConfig {
  final bool enableCrashMonitoring;
  final bool enableAnrMonitoring;
  final bool enableNetworkLogging;
  final bool enableApiResponseLogging;
  final int maxLogEntries;

  const LumioConfig({
    this.enableCrashMonitoring = true,
    this.enableAnrMonitoring = true,
    this.enableNetworkLogging = true,
    this.enableApiResponseLogging = true,
    this.maxLogEntries = 1000,
  });
}
