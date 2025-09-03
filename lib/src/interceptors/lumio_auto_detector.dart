import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'lumio_http_interceptor.dart';
import 'lumio_dio_interceptor.dart';
import 'lumio_global_interceptor.dart';

/// Optimized auto-detector for HTTP clients with better resource management
class LumioAutoDetector {
  static bool _isEnabled = false;
  static bool _dioDetected = false;
  static bool _httpDetected = false;
  static Timer? _detectionTimer;
  static final Set<Dio> _detectedDioInstances = <Dio>{};
  static final Set<http.Client> _detectedHttpClients = <http.Client>{};
  static final Map<String, DateTime> _lastDetectionTime = {};
  static const Duration _detectionInterval = Duration(seconds: 3);
  static const int _maxInstances = 50; // Prevent memory leaks

  /// Enable auto-detection mode with optimized settings
  static Future<void> enable() async {
    if (_isEnabled) return;

    _isEnabled = true;
    debugPrint('Lumio: Auto-detection mode enabled');

    // Start periodic detection with longer interval for better performance
    _detectionTimer = Timer.periodic(_detectionInterval, (timer) {
      _detectAndInject();
    });

    // Initial detection
    await _detectAndInject();
  }

  /// Disable auto-detection mode and clean up resources
  static void disable() {
    _isEnabled = false;
    _detectionTimer?.cancel();
    _detectionTimer = null;
    _detectedDioInstances.clear();
    _detectedHttpClients.clear();
    _lastDetectionTime.clear();
    debugPrint('Lumio: Auto-detection mode disabled');
  }

  /// Detect HTTP clients and inject interceptors with rate limiting
  static Future<void> _detectAndInject() async {
    if (!_isEnabled) return;

    final now = DateTime.now();
    
    try {
      // Detect Dio instances with rate limiting
      if (!_lastDetectionTime.containsKey('dio') || 
          now.difference(_lastDetectionTime['dio']!) > _detectionInterval) {
        await _detectDioInstances();
        _lastDetectionTime['dio'] = now;
      }
      
      // Detect HTTP clients with rate limiting
      if (!_lastDetectionTime.containsKey('http') || 
          now.difference(_lastDetectionTime['http']!) > _detectionInterval) {
        await _detectHttpClients();
        _lastDetectionTime['http'] = now;
      }
      
    } catch (e) {
      debugPrint('Lumio: Auto-detection error: $e');
    }
  }

  /// Detect Dio instances with memory management
  static Future<void> _detectDioInstances() async {
    try {
      if (!_dioDetected) {
        _dioDetected = true;
        debugPrint('Lumio: Dio detected, auto-injecting interceptor');
      }
      
      // Clean up invalid instances
      _detectedDioInstances.removeWhere((dio) => 
          dio.interceptors.isEmpty || !dio.interceptors.any((i) => i is LumioDioInterceptor));
      
    } catch (e) {
      debugPrint('Lumio: Dio detection error: $e');
    }
  }

  /// Detect HTTP clients with memory management
  static Future<void> _detectHttpClients() async {
    try {
      if (!_httpDetected) {
        _httpDetected = true;
        debugPrint('Lumio: HTTP package detected');
      }
      
      // Clean up invalid clients
      _detectedHttpClients.removeWhere((client) => client == null);
      
    } catch (e) {
      debugPrint('Lumio: HTTP detection error: $e');
    }
  }

  /// Register a Dio instance for auto-injection with memory limits
  static void registerDioInstance(Dio dio) {
    if (!_isEnabled || dio == null) return;

    // Prevent memory leaks by limiting instances
    if (_detectedDioInstances.length >= _maxInstances) {
      debugPrint('Lumio: Maximum Dio instances reached, removing oldest');
      _detectedDioInstances.remove(_detectedDioInstances.first);
    }

    if (!_detectedDioInstances.contains(dio)) {
      _detectedDioInstances.add(dio);
      
      // Check if it already has Lumio interceptor
      bool hasLumioInterceptor = dio.interceptors.any(
        (interceptor) => interceptor is LumioDioInterceptor
      );

      if (!hasLumioInterceptor) {
        dio.addLumioInterceptor();
        debugPrint('Lumio: Auto-injected interceptor into Dio instance');
      }
    }
  }

  /// Register an HTTP client for auto-injection with memory limits
  static void registerHttpClient(http.Client client) {
    if (!_isEnabled || client == null) return;

    // Prevent memory leaks by limiting instances
    if (_detectedHttpClients.length >= _maxInstances) {
      debugPrint('Lumio: Maximum HTTP clients reached, removing oldest');
      _detectedHttpClients.remove(_detectedHttpClients.first);
    }

    if (!_detectedHttpClients.contains(client)) {
      _detectedHttpClients.add(client);
      debugPrint('Lumio: Registered HTTP client for monitoring');
    }
  }

  /// Get all detected Dio instances (read-only)
  static Set<Dio> get detectedDioInstances => Set.unmodifiable(_detectedDioInstances);

  /// Get all detected HTTP clients (read-only)
  static Set<http.Client> get detectedHttpClients => Set.unmodifiable(_detectedHttpClients);

  /// Check if auto-detection is enabled
  static bool get isEnabled => _isEnabled;

  /// Check if Dio was detected
  static bool get dioDetected => _dioDetected;

  /// Check if HTTP was detected
  static bool get httpDetected => _httpDetected;

  /// Get detection statistics
  static Map<String, dynamic> get statistics {
    return {
      'isEnabled': _isEnabled,
      'dioDetected': _dioDetected,
      'httpDetected': _httpDetected,
      'dioInstances': _detectedDioInstances.length,
      'httpClients': _detectedHttpClients.length,
      'maxInstances': _maxInstances,
      'lastDetectionTimes': Map.unmodifiable(_lastDetectionTime),
    };
  }

  /// Clean up resources and remove invalid instances
  static void cleanup() {
    _detectedDioInstances.removeWhere((dio) => 
        dio.interceptors.isEmpty || !dio.interceptors.any((i) => i is LumioDioInterceptor));
    _detectedHttpClients.removeWhere((client) => client == null);
    _lastDetectionTime.clear();
  }
}

/// Optimized extension to automatically register Dio instances
extension LumioDioAutoRegistration on Dio {
  /// Register this Dio instance for Lumio auto-monitoring
  void registerWithLumio() {
    LumioAutoDetector.registerDioInstance(this);
  }
}

/// Optimized extension to automatically register HTTP clients
extension LumioHttpAutoRegistration on http.Client {
  /// Register this HTTP client for Lumio auto-monitoring
  void registerWithLumio() {
    LumioAutoDetector.registerHttpClient(this);
  }
}
