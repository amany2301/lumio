import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'crash_data.dart';

/// Manages crash reports and provides APIs for crash monitoring
class CrashManager {
  static final CrashManager _instance = CrashManager._internal();
  factory CrashManager() => _instance;
  CrashManager._internal();

  final List<CrashReport> _crashes = [];
  final List<CrashBreadcrumb> _breadcrumbs = [];
  final StreamController<CrashReport> _crashController = StreamController<CrashReport>.broadcast();
  final StreamController<CrashStats> _statsController = StreamController<CrashStats>.broadcast();
  
  int _maxStoredCrashes = 500;
  final int _maxBreadcrumbs = 100;
  bool _isEnabled = true;
  String? _currentUserId;
  Map<String, String> _deviceInfo = {};

  /// Stream of crash reports
  Stream<CrashReport> get crashStream => _crashController.stream;
  
  /// Stream of crash statistics
  Stream<CrashStats> get statsStream => _statsController.stream;

  /// Get all crash reports
  List<CrashReport> get allCrashes => List.unmodifiable(_crashes);

  /// Get all breadcrumbs
  List<CrashBreadcrumb> get allBreadcrumbs => List.unmodifiable(_breadcrumbs);

  /// Get crash statistics
  CrashStats get stats {
    final total = _crashes.length;
    final flutter = _crashes.where((c) => c.type == CrashType.flutter).length;
    final native = _crashes.where((c) => c.type == CrashType.native).length;
    final anr = _crashes.where((c) => c.type == CrashType.anr).length;
    final network = _crashes.where((c) => c.type == CrashType.network).length;
    final memory = _crashes.where((c) => c.type == CrashType.memory).length;
    final custom = _crashes.where((c) => c.type == CrashType.custom).length;

    final severityBreakdown = <CrashSeverity, int>{};
    for (final severity in CrashSeverity.values) {
      severityBreakdown[severity] = _crashes.where((c) => c.severity == severity).length;
    }

    final lastCrash = _crashes.isNotEmpty ? _crashes.first.timestamp : null;
    
    // Calculate crash-free rate (simplified - in real app you'd track sessions)
    final crashFreeRate = total == 0 ? 100.0 : max(0.0, 100.0 - (total * 0.1));

    return CrashStats(
      totalCrashes: total,
      flutterCrashes: flutter,
      nativeCrashes: native,
      anrEvents: anr,
      networkErrors: network,
      memoryIssues: memory,
      customErrors: custom,
      severityBreakdown: severityBreakdown,
      lastCrashTime: lastCrash,
      crashFreeRate: crashFreeRate,
    );
  }

  /// Initialize crash monitoring with device info
  void initialize({
    String? userId,
    Map<String, String>? deviceInfo,
  }) {
    _currentUserId = userId;
    _deviceInfo = deviceInfo ?? _getDefaultDeviceInfo();
    
    // Set up Flutter error handler
    FlutterError.onError = (FlutterErrorDetails details) {
      recordCrash(
        title: 'Flutter Error',
        message: details.exception.toString(),
        stackTrace: details.stack?.toString() ?? '',
        type: CrashType.flutter,
        severity: CrashSeverity.error,
        context: {
          'library': details.library,
          'context': details.context?.toString(),
          'informationCollector': details.informationCollector?.toString(),
        },
      );
    };

    // Set up platform dispatcher error handler
    PlatformDispatcher.instance.onError = (error, stack) {
      recordCrash(
        title: 'Platform Error',
        message: error.toString(),
        stackTrace: stack.toString(),
        type: CrashType.flutter,
        severity: CrashSeverity.critical,
      );
      return true;
    };
  }

  /// Enable or disable crash monitoring
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Set current user ID
  void setUserId(String? userId) {
    _currentUserId = userId;
  }

  /// Set device information
  void setDeviceInfo(Map<String, String> deviceInfo) {
    _deviceInfo = deviceInfo;
  }

  /// Set maximum number of stored crashes
  void setMaxStoredCrashes(int maxCrashes) {
    _maxStoredCrashes = maxCrashes;
    _trimCrashesIfNeeded();
  }

  /// Record a crash report
  String recordCrash({
    required String title,
    required String message,
    required String stackTrace,
    CrashType type = CrashType.custom,
    CrashSeverity severity = CrashSeverity.error,
    Map<String, dynamic> context = const {},
    Map<String, dynamic> customData = const {},
  }) {
    if (!_isEnabled) return '';

    final id = _generateId();
    final crash = CrashReport(
      id: id,
      title: title,
      message: message,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
      type: type,
      severity: severity,
      context: Map<String, dynamic>.from(context),
      userId: _currentUserId,
      deviceInfo: Map<String, String>.from(_deviceInfo),
      customData: Map<String, dynamic>.from(customData),
    );

    _crashes.insert(0, crash);
    _trimCrashesIfNeeded();
    
    _crashController.add(crash);
    _statsController.add(stats);

    // Log to console for debugging
    debugPrint('[AppPulse] ${crash.icon} Crash recorded: ${crash.title}');
    debugPrint('[AppPulse] Message: ${crash.message}');
    if (kDebugMode) {
      debugPrint('[AppPulse] Stack trace:\n${crash.stackTrace}');
    }

    return id;
  }

  /// Record a breadcrumb
  void recordBreadcrumb({
    required String category,
    required String message,
    BreadcrumbLevel level = BreadcrumbLevel.info,
    Map<String, dynamic> data = const {},
  }) {
    if (!_isEnabled) return;

    final breadcrumb = CrashBreadcrumb(
      id: _generateId(),
      timestamp: DateTime.now(),
      category: category,
      message: message,
      level: level,
      data: Map<String, dynamic>.from(data),
    );

    _breadcrumbs.insert(0, breadcrumb);
    
    // Trim breadcrumbs if needed
    if (_breadcrumbs.length > _maxBreadcrumbs) {
      _breadcrumbs.removeRange(_maxBreadcrumbs, _breadcrumbs.length);
    }
  }

  /// Filter crashes by various criteria
  List<CrashReport> filterCrashes({
    CrashType? type,
    CrashSeverity? severity,
    String? userId,
    DateTime? startTime,
    DateTime? endTime,
    String? searchQuery,
  }) {
    return _crashes.where((crash) {
      // Type filter
      if (type != null && crash.type != type) {
        return false;
      }

      // Severity filter
      if (severity != null && crash.severity != severity) {
        return false;
      }

      // User ID filter
      if (userId != null && crash.userId != userId) {
        return false;
      }

      // Time range filter
      if (startTime != null && crash.timestamp.isBefore(startTime)) {
        return false;
      }
      if (endTime != null && crash.timestamp.isAfter(endTime)) {
        return false;
      }

      // Search query filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        return crash.title.toLowerCase().contains(query) ||
               crash.message.toLowerCase().contains(query) ||
               crash.stackTrace.toLowerCase().contains(query);
      }

      return true;
    }).toList();
  }

  /// Search crashes by text
  List<CrashReport> searchCrashes(String query) {
    if (query.isEmpty) return _crashes;

    final lowerQuery = query.toLowerCase();
    return _crashes.where((crash) {
      return crash.title.toLowerCase().contains(lowerQuery) ||
             crash.message.toLowerCase().contains(lowerQuery) ||
             crash.stackTrace.toLowerCase().contains(lowerQuery) ||
             crash.context.toString().toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Get a specific crash by ID
  CrashReport? getCrash(String id) {
    try {
      return _crashes.firstWhere((crash) => crash.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get breadcrumbs for a specific time range (useful for crash context)
  List<CrashBreadcrumb> getBreadcrumbsForTimeRange({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    return _breadcrumbs.where((breadcrumb) {
      return breadcrumb.timestamp.isAfter(startTime) &&
             breadcrumb.timestamp.isBefore(endTime);
    }).toList();
  }

  /// Get breadcrumbs leading up to a crash (last 10 minutes)
  List<CrashBreadcrumb> getBreadcrumbsForCrash(CrashReport crash) {
    final startTime = crash.timestamp.subtract(const Duration(minutes: 10));
    return getBreadcrumbsForTimeRange(
      startTime: startTime,
      endTime: crash.timestamp,
    );
  }

  /// Clear all crashes
  void clearAll() {
    _crashes.clear();
    _breadcrumbs.clear();
    _statsController.add(stats);
  }

  /// Clear crashes older than specified duration
  void clearOldCrashes(Duration maxAge) {
    final cutoff = DateTime.now().subtract(maxAge);
    _crashes.removeWhere((crash) => crash.timestamp.isBefore(cutoff));
    _breadcrumbs.removeWhere((breadcrumb) => breadcrumb.timestamp.isBefore(cutoff));
    _statsController.add(stats);
  }

  /// Export crashes as JSON
  Map<String, dynamic> exportAsJson({
    DateTime? startTime,
    DateTime? endTime,
  }) {
    final crashesToExport = filterCrashes(startTime: startTime, endTime: endTime);
    final breadcrumbsToExport = startTime != null && endTime != null
      ? getBreadcrumbsForTimeRange(startTime: startTime, endTime: endTime)
      : _breadcrumbs;

    return {
      'timestamp': DateTime.now().toIso8601String(),
      'totalCrashes': crashesToExport.length,
      'totalBreadcrumbs': breadcrumbsToExport.length,
      'stats': stats.toJson(),
      'crashes': crashesToExport.map((crash) => crash.toJson()).toList(),
      'breadcrumbs': breadcrumbsToExport.map((breadcrumb) => breadcrumb.toJson()).toList(),
      'deviceInfo': _deviceInfo,
      'userId': _currentUserId,
    };
  }

  /// Generate a unique ID
  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    return '${timestamp}_$random';
  }

  /// Trim crashes if we exceed the maximum
  void _trimCrashesIfNeeded() {
    if (_crashes.length > _maxStoredCrashes) {
      _crashes.removeRange(_maxStoredCrashes, _crashes.length);
    }
  }

  /// Get default device information
  Map<String, String> _getDefaultDeviceInfo() {
    return {
      'platform': Platform.operatingSystem,
      'platformVersion': Platform.operatingSystemVersion,
      'locale': Platform.localeName,
      'hostname': Platform.localHostname,
      'numberOfProcessors': Platform.numberOfProcessors.toString(),
    };
  }

  /// Dispose resources
  void dispose() {
    _crashController.close();
    _statsController.close();
  }
}
