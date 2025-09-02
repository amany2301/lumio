import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Enhanced logger for Lumio with cURL generation and better formatting
class LumioLogger {
  static const String _tag = '[Lumio]';
  static bool _enableDetailedLogging = true;
  static bool _enableCurlGeneration = true;

  /// Enable or disable detailed logging
  static void setDetailedLogging(bool enabled) {
    _enableDetailedLogging = enabled;
  }

  /// Enable or disable cURL generation
  static void setCurlGeneration(bool enabled) {
    _enableCurlGeneration = enabled;
  }

  /// Log API response with enhanced formatting
  static void logApiResponse({
    required String url,
    required int statusCode,
    required String method,
    required String responseBody,
    Map<String, String>? headers,
    String? requestBody,
    int? durationMs,
  }) {
    if (!_enableDetailedLogging) return;

    final timestamp = DateTime.now().toIso8601String();
    final separator = '=' * 60;
    
    debugPrint('$_tag $separator');
    debugPrint('$_tag API RESPONSE [$timestamp]');
    debugPrint('$_tag $separator');
    debugPrint('$_tag Method: $method');
    debugPrint('$_tag URL: $url');
    debugPrint('$_tag Status: $statusCode ${_getStatusText(statusCode)}');
    
    if (durationMs != null) {
      debugPrint('$_tag Duration: ${durationMs}ms');
    }
    
    if (headers != null && headers.isNotEmpty) {
      debugPrint('$_tag Headers:');
      headers.forEach((key, value) {
        debugPrint('$_tag   $key: $value');
      });
    }
    
    if (requestBody != null && requestBody.isNotEmpty) {
      debugPrint('$_tag Request Body:');
      debugPrint('$_tag   ${_formatJson(requestBody)}');
    }
    
    debugPrint('$_tag Response Body:');
    debugPrint('$_tag   ${_formatJson(responseBody)}');
    
    // Generate cURL command
    if (_enableCurlGeneration) {
      final curlCommand = _generateCurlCommand(
        method: method,
        url: url,
        headers: headers,
        body: requestBody,
      );
      debugPrint(_tag);
      debugPrint('$_tag cURL Command:');
      debugPrint('$_tag $curlCommand');
    }
    
    debugPrint('$_tag $separator');
  }

  /// Log network call with enhanced formatting
  static void logNetworkCall({
    required String method,
    required String url,
    required int durationMs,
    Map<String, String>? headers,
    String? requestBody,
  }) {
    if (!_enableDetailedLogging) return;

    final timestamp = DateTime.now().toIso8601String();
    final separator = '-' * 40;
    
    debugPrint('$_tag $separator');
    debugPrint('$_tag NETWORK CALL [$timestamp]');
    debugPrint('$_tag $method $url');
    debugPrint('$_tag Duration: ${durationMs}ms');
    
    if (headers != null && headers.isNotEmpty) {
      debugPrint('$_tag Headers: ${headers.length} items');
    }
    
    if (requestBody != null && requestBody.isNotEmpty) {
      debugPrint('$_tag Request Body Size: ${requestBody.length} chars');
    }
    
    debugPrint('$_tag $separator');
  }

  /// Log crash with enhanced formatting
  static void logCrash({
    required String error,
    required String stackTrace,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final separator = '!' * 60;
    
    debugPrint('$_tag $separator');
    debugPrint('$_tag CRASH DETECTED [$timestamp]');
    debugPrint('$_tag $separator');
    debugPrint('$_tag Error: $error');
    debugPrint('$_tag Stack Trace:');
    debugPrint('$_tag $stackTrace');
    debugPrint('$_tag $separator');
  }

  /// Log ANR with enhanced formatting
  static void logAnr({
    required String message,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final separator = '#' * 40;
    
    debugPrint('$_tag $separator');
    debugPrint('$_tag ANR DETECTED [$timestamp]');
    debugPrint('$_tag $message');
    debugPrint('$_tag $separator');
  }

  /// Generate cURL command from request details
  static String _generateCurlCommand({
    required String method,
    required String url,
    Map<String, String>? headers,
    String? body,
  }) {
    final buffer = StringBuffer();
    buffer.write('curl -X $method');
    
    // Add headers
    if (headers != null && headers.isNotEmpty) {
      headers.forEach((key, value) {
        buffer.write(' \\\n  -H "$key: $value"');
      });
    }
    
    // Add body for POST/PUT/PATCH requests
    if (body != null && body.isNotEmpty && 
        ['POST', 'PUT', 'PATCH'].contains(method.toUpperCase())) {
      final escapedBody = body.replaceAll('"', '\\"');
      buffer.write(' \\\n  -d "$escapedBody"');
    }
    
    // Add URL
    buffer.write(' \\\n  "$url"');
    
    return buffer.toString();
  }

  /// Format JSON string for better readability
  static String _formatJson(String jsonString) {
    try {
      final dynamic jsonObject = jsonDecode(jsonString);
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(jsonObject);
    } catch (e) {
      // If it's not valid JSON, return as is
      return jsonString.length > 500 
        ? '${jsonString.substring(0, 500)}...\n[Truncated - ${jsonString.length} total chars]'
        : jsonString;
    }
  }

  /// Get status text for HTTP status codes
  static String _getStatusText(int statusCode) {
    switch (statusCode) {
      case 200: return '(OK)';
      case 201: return '(Created)';
      case 204: return '(No Content)';
      case 400: return '(Bad Request)';
      case 401: return '(Unauthorized)';
      case 403: return '(Forbidden)';
      case 404: return '(Not Found)';
      case 500: return '(Internal Server Error)';
      case 502: return '(Bad Gateway)';
      case 503: return '(Service Unavailable)';
      default: return '';
    }
  }

  /// Print a simple log message
  static void log(String message) {
    debugPrint('$_tag $message');
  }

  /// Print an info message
  static void info(String message) {
    debugPrint('$_tag ℹ️ $message');
  }

  /// Print a warning message
  static void warning(String message) {
    debugPrint('$_tag ⚠️ $message');
  }

  /// Print an error message
  static void error(String message) {
    debugPrint('$_tag ❌ $message');
  }

  /// Print a success message
  static void success(String message) {
    debugPrint('$_tag ✅ $message');
  }
}
