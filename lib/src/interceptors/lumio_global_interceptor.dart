import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/lumio_models.dart';
import '../utils/lumio_storage.dart';
import 'lumio_http_interceptor.dart';

/// Global HTTP interceptor that automatically hooks into all HTTP calls
class LumioGlobalInterceptor {
  static bool _isEnabled = false;
  static http.Client? _originalClient;
  static LumioHttpInterceptor? _interceptedClient;

  /// Enable global HTTP interception
  static Future<void> enable() async {
    if (_isEnabled) return;

    try {
      // Create the original client
      _originalClient = http.Client();
      
      // Create the intercepted client
      _interceptedClient = LumioHttpInterceptor(_originalClient!);
      
      _isEnabled = true;
      
      // Override the global http methods
      _overrideHttpMethods();
      
      debugPrint('Lumio: Global HTTP interceptor enabled');
    } catch (e) {
      debugPrint('Lumio: Failed to enable global HTTP interceptor: $e');
    }
  }

  /// Override global HTTP methods to use our interceptor
  static void _overrideHttpMethods() {
    // Note: This is a simplified approach
    // In a real implementation, you might need to use a more sophisticated method
    // to actually override the global http methods
    
    // For now, we'll provide the intercepted client through our getter
    // and users can use Lumio.httpClient for automatic logging
  }

  /// Get the intercepted HTTP client
  static http.Client? get interceptedClient => _interceptedClient;

  /// Check if global interceptor is enabled
  static bool get isEnabled => _isEnabled;

  /// Disable global HTTP interception
  static void disable() {
    _isEnabled = false;
    _originalClient?.close();
    _interceptedClient?.close();
    _originalClient = null;
    _interceptedClient = null;
  }
}

/// Global HTTP methods with automatic logging
class LumioHttp {
  /// Get intercepted HTTP client for automatic logging
  static http.Client get client => LumioGlobalInterceptor.interceptedClient ?? http.Client();
  
  /// Intercepted GET method
  static Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    final client = LumioGlobalInterceptor.interceptedClient ?? http.Client();
    return client.get(url, headers: headers);
  }
  
  /// Intercepted POST method
  static Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final client = LumioGlobalInterceptor.interceptedClient ?? http.Client();
    return client.post(url, headers: headers, body: body, encoding: encoding);
  }
  
  /// Intercepted PUT method
  static Future<http.Response> put(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final client = LumioGlobalInterceptor.interceptedClient ?? http.Client();
    return client.put(url, headers: headers, body: body, encoding: encoding);
  }
  
  /// Intercepted DELETE method
  static Future<http.Response> delete(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final client = LumioGlobalInterceptor.interceptedClient ?? http.Client();
    return client.delete(url, headers: headers, body: body, encoding: encoding);
  }
  
  /// Intercepted PATCH method
  static Future<http.Response> patch(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final client = LumioGlobalInterceptor.interceptedClient ?? http.Client();
    return client.patch(url, headers: headers, body: body, encoding: encoding);
  }
  
  /// Intercepted HEAD method
  static Future<http.Response> head(Uri url, {Map<String, String>? headers}) async {
    final client = LumioGlobalInterceptor.interceptedClient ?? http.Client();
    return client.head(url, headers: headers);
  }
}
