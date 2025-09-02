import 'package:flutter/material.dart';
import '../plugin_base.dart';
import 'network_manager.dart';
import 'network_screen.dart';

/// Network Plugin for monitoring HTTP requests and responses
/// Similar to Android Pluto's network plugin
class NetworkPlugin extends Plugin {
  final NetworkManager _networkManager = NetworkManager();
  final NetworkPluginConfiguration _config;
  
  NetworkPlugin({
    NetworkPluginConfiguration? configuration,
  }) : _config = configuration ?? const NetworkPluginConfiguration();
  
  @override
  String get name => 'Network Plugin';
  
  @override
  String get description => 'Monitor HTTP requests, responses, and API calls with detailed inspection';
  
  @override
  String get version => '1.0.0';
  
  @override
  IconData? get icon => Icons.network_check;
  
  @override
  Color? get color => Colors.blue;
  
  @override
  bool get isEnabled => _config.enabled;
  
  @override
  PluginConfiguration? get configuration => _config;
  
  @override
  PluginStatistics get statistics {
    final requests = _networkManager.getAllRequests();
    final errors = requests.where((r) => r.statusCode != null && r.statusCode! >= 400).length;
    final warnings = requests.where((r) => r.statusCode != null && r.statusCode! >= 300 && r.statusCode! < 400).length;
    
    return PluginStatistics(
      totalItems: requests.length,
      errorCount: errors,
      warningCount: warnings,
      lastActivity: requests.isNotEmpty ? requests.last.timestamp : DateTime.now(),
      uptime: DateTime.now().difference(_networkManager.startTime),
    );
  }
  
  @override
  void initialize() {
    if (_config.enableCurlGeneration) {
      _networkManager.enableCurlGeneration();
    }
    
    if (_config.enableBodyInspection) {
      _networkManager.enableBodyInspection();
    }
    
    _networkManager.setMaxStoredRequests(_config.maxStoredRequests);
    
    // Start monitoring
    _networkManager.start();
  }
  
  @override
  void dispose() {
    _networkManager.stop();
  }
  
  @override
  Widget buildDebugScreen() {
    return NetworkScreen(
      networkManager: _networkManager,
      configuration: _config,
    );
  }
  
  @override
  Future<Map<String, dynamic>> exportData() async {
    final baseData = await super.exportData();
    final requests = _networkManager.getAllRequests();
    
    return {
      ...baseData,
      'requests': requests.map((r) => r.toJson()).toList(),
      'statistics': {
        'totalRequests': requests.length,
        'successfulRequests': requests.where((r) => r.statusCode != null && r.statusCode! < 400).length,
        'failedRequests': requests.where((r) => r.statusCode != null && r.statusCode! >= 400).length,
        'averageResponseTime': requests.isNotEmpty 
          ? requests.map((r) => r.durationMs).reduce((a, b) => a + b) / requests.length 
          : 0,
      },
    };
  }
  
  /// Get network manager instance
  NetworkManager get networkManager => _networkManager;
  
  /// Clear all stored requests
  void clearRequests() {
    _networkManager.clearAllRequests();
  }
  
  /// Get request by ID
  NetworkRequest? getRequest(String id) {
    return _networkManager.getRequest(id);
  }
  
  /// Get all requests
  List<NetworkRequest> getAllRequests() {
    return _networkManager.getAllRequests();
  }
  
  /// Get requests by status code
  List<NetworkRequest> getRequestsByStatusCode(int statusCode) {
    return _networkManager.getAllRequests()
        .where((r) => r.statusCode == statusCode)
        .toList();
  }
  
  /// Get requests by method
  List<NetworkRequest> getRequestsByMethod(String method) {
    return _networkManager.getAllRequests()
        .where((r) => r.method.toUpperCase() == method.toUpperCase())
        .toList();
  }
  
  /// Get requests by URL pattern
  List<NetworkRequest> getRequestsByUrlPattern(String pattern) {
    return _networkManager.getAllRequests()
        .where((r) => r.url.contains(pattern))
        .toList();
  }
}

/// Network plugin configuration
class NetworkPluginConfiguration extends PluginConfiguration {
  final bool enableCurlGeneration;
  final bool enableBodyInspection;
  final bool enableHeaderInspection;
  final int maxStoredRequests;
  final bool enabled;
  final Duration requestTimeout;
  
  const NetworkPluginConfiguration({
    super.enableNotifications = true,
    super.enableExport = true,
    super.maxStoredItems = 1000,
    super.dataRetentionPeriod = const Duration(days: 7),
    this.enableCurlGeneration = true,
    this.enableBodyInspection = true,
    this.enableHeaderInspection = true,
    this.maxStoredRequests = 1000,
    this.enabled = true,
    this.requestTimeout = const Duration(seconds: 30),
  });
  
  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'enableCurlGeneration': enableCurlGeneration,
      'enableBodyInspection': enableBodyInspection,
      'enableHeaderInspection': enableHeaderInspection,
      'maxStoredRequests': maxStoredRequests,
      'enabled': enabled,
      'requestTimeout': requestTimeout.inSeconds,
    };
  }
}
