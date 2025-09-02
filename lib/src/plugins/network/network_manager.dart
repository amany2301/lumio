import 'dart:async';
import 'dart:math';
import 'network_data.dart';

/// Manages network call data and provides APIs for monitoring
class NetworkManager {
  static final NetworkManager _instance = NetworkManager._internal();
  factory NetworkManager() => _instance;
  NetworkManager._internal();

  final List<NetworkCall> _networkCalls = [];
  final StreamController<NetworkCall> _networkCallController = StreamController<NetworkCall>.broadcast();
  final StreamController<NetworkStats> _statsController = StreamController<NetworkStats>.broadcast();
  
  int _maxStoredCalls = 1000;
  bool _isEnabled = true;

  /// Stream of network calls
  Stream<NetworkCall> get networkCallStream => _networkCallController.stream;
  
  /// Stream of network statistics
  Stream<NetworkStats> get statsStream => _statsController.stream;

  /// Get all network calls
  List<NetworkCall> get allCalls => List.unmodifiable(_networkCalls);

  /// Get network statistics
  NetworkStats get stats {
    final total = _networkCalls.length;
    final successful = _networkCalls.where((call) => call.isSuccess).length;
    final failed = _networkCalls.where((call) => call.hasError).length;
    final pending = _networkCalls.where((call) => !call.isCompleted).length;
    
    final completedCalls = _networkCalls.where((call) => call.isCompleted && call.duration != null);
    final avgTime = completedCalls.isEmpty 
      ? 0.0 
      : completedCalls.map((call) => call.duration!).reduce((a, b) => a + b) / completedCalls.length;
    
    final totalData = _networkCalls.fold<int>(0, (sum, call) {
      return sum + (call.requestSize ?? 0) + (call.responseSize ?? 0);
    });

    return NetworkStats(
      totalRequests: total,
      successfulRequests: successful,
      failedRequests: failed,
      pendingRequests: pending,
      averageResponseTime: avgTime,
      totalDataTransferred: totalData,
    );
  }

  /// Enable or disable network monitoring
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Set maximum number of stored network calls
  void setMaxStoredCalls(int maxCalls) {
    _maxStoredCalls = maxCalls;
    _trimCallsIfNeeded();
  }

  /// Record a new network request
  String recordRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    String? body,
  }) {
    if (!_isEnabled) return '';

    final id = _generateId();
    final call = NetworkCall(
      id: id,
      method: method.toUpperCase(),
      url: url,
      requestHeaders: headers ?? {},
      requestBody: body,
      requestTime: DateTime.now(),
    );

    _networkCalls.insert(0, call);
    _trimCallsIfNeeded();
    
    _networkCallController.add(call);
    _statsController.add(stats);

    return id;
  }

  /// Record the response for a network request
  void recordResponse({
    required String id,
    int? statusCode,
    Map<String, String>? headers,
    String? body,
    String? error,
  }) {
    if (!_isEnabled) return;

    final index = _networkCalls.indexWhere((call) => call.id == id);
    if (index == -1) return;

    final updatedCall = _networkCalls[index].copyWithResponse(
      statusCode: statusCode,
      responseHeaders: headers,
      responseBody: body,
      error: error,
    );

    _networkCalls[index] = updatedCall;
    
    _networkCallController.add(updatedCall);
    _statsController.add(stats);
  }

  /// Filter network calls by various criteria
  List<NetworkCall> filterCalls({
    String? method,
    String? urlPattern,
    int? statusCode,
    bool? isSuccess,
    bool? hasError,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return _networkCalls.where((call) {
      // Method filter
      if (method != null && call.method != method.toUpperCase()) {
        return false;
      }

      // URL pattern filter
      if (urlPattern != null && !call.url.toLowerCase().contains(urlPattern.toLowerCase())) {
        return false;
      }

      // Status code filter
      if (statusCode != null && call.statusCode != statusCode) {
        return false;
      }

      // Success filter
      if (isSuccess != null && call.isSuccess != isSuccess) {
        return false;
      }

      // Error filter
      if (hasError != null && call.hasError != hasError) {
        return false;
      }

      // Time range filter
      if (startTime != null && call.requestTime.isBefore(startTime)) {
        return false;
      }
      if (endTime != null && call.requestTime.isAfter(endTime)) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Search network calls by URL or response content
  List<NetworkCall> searchCalls(String query) {
    if (query.isEmpty) return _networkCalls;

    final lowerQuery = query.toLowerCase();
    return _networkCalls.where((call) {
      return call.url.toLowerCase().contains(lowerQuery) ||
             (call.requestBody?.toLowerCase().contains(lowerQuery) ?? false) ||
             (call.responseBody?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// Get a specific network call by ID
  NetworkCall? getCall(String id) {
    try {
      return _networkCalls.firstWhere((call) => call.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Clear all network calls
  void clearAll() {
    _networkCalls.clear();
    _statsController.add(stats);
  }

  /// Export network calls as JSON
  Map<String, dynamic> exportAsJson({
    DateTime? startTime,
    DateTime? endTime,
  }) {
    final callsToExport = filterCalls(startTime: startTime, endTime: endTime);
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'totalCalls': callsToExport.length,
      'stats': stats.toJson(),
      'calls': callsToExport.map((call) => call.toJson()).toList(),
    };
  }

  /// Generate a unique ID for network calls
  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    return '${timestamp}_$random';
  }

  /// Trim network calls if we exceed the maximum
  void _trimCallsIfNeeded() {
    if (_networkCalls.length > _maxStoredCalls) {
      _networkCalls.removeRange(_maxStoredCalls, _networkCalls.length);
    }
  }

  /// Dispose resources
  void dispose() {
    _networkCallController.close();
    _statsController.close();
  }
}

/// Extension for NetworkStats JSON conversion
extension NetworkStatsJson on NetworkStats {
  Map<String, dynamic> toJson() {
    return {
      'totalRequests': totalRequests,
      'successfulRequests': successfulRequests,
      'failedRequests': failedRequests,
      'pendingRequests': pendingRequests,
      'averageResponseTime': averageResponseTime,
      'totalDataTransferred': totalDataTransferred,
      'successRate': successRate,
      'failureRate': failureRate,
    };
  }
}
