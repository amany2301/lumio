import 'dart:io';
import 'dart:convert';

import '../../lumio.dart';
import '../utils/lumio_logger.dart';

/// HTTP Client wrapper that automatically logs network calls and API responses
class LumioHttpClient {
  final HttpClient _httpClient;

  LumioHttpClient() : _httpClient = HttpClient();

  /// Perform a GET request with automatic logging
  Future<HttpClientResponse> get(String url) async {
    return _performRequest('GET', url, null);
  }

  /// Perform a POST request with automatic logging
  Future<HttpClientResponse> post(String url, {dynamic body}) async {
    return _performRequest('POST', url, body);
  }

  /// Perform a PUT request with automatic logging
  Future<HttpClientResponse> put(String url, {dynamic body}) async {
    return _performRequest('PUT', url, body);
  }

  /// Perform a DELETE request with automatic logging
  Future<HttpClientResponse> delete(String url) async {
    return _performRequest('DELETE', url, null);
  }

  /// Perform a PATCH request with automatic logging
  Future<HttpClientResponse> patch(String url, {dynamic body}) async {
    return _performRequest('PATCH', url, body);
  }

  Future<HttpClientResponse> _performRequest(String method, String url, dynamic body) async {
    final stopwatch = Stopwatch()..start();
    
    String? requestBody;
    Map<String, String> requestHeaders = {};
    
    try {
      final uri = Uri.parse(url);
      final request = await _httpClient.openUrl(method, uri);
      
      // Collect request headers
      request.headers.forEach((name, values) {
        requestHeaders[name] = values.join(', ');
      });
      
      if (body != null) {
        request.headers.contentType = ContentType.json;
        requestBody = jsonEncode(body);
        request.write(requestBody);
        requestHeaders['content-type'] = 'application/json';
      }
      
      final response = await request.close();
      stopwatch.stop();
      
      // Read response body for logging
      final responseBody = await response.transform(utf8.decoder).join();
      
      // Collect response headers
      Map<String, String> responseHeaders = {};
      response.headers.forEach((name, values) {
        responseHeaders[name] = values.join(', ');
      });
      
      // Log the network call and API response
      LumioLogger.info('Network Request: $method $url');
      LumioLogger.info('Status Code: ${response.statusCode}');
      LumioLogger.info('Duration: ${stopwatch.elapsedMilliseconds}ms');
      
      // Log to Lumio for platform logging
      Lumio.logNetworkCall(method, url, stopwatch.elapsedMilliseconds);
      Lumio.logApiResponse(url, response.statusCode, responseBody);
      
      return response;
    } catch (e) {
      stopwatch.stop();
      
      // Enhanced error logging
      LumioLogger.error('Network request failed: $method $url');
      LumioLogger.error('Error: $e');
      LumioLogger.error('Duration: ${stopwatch.elapsedMilliseconds}ms');
      
      // Log failed network call
      Lumio.logNetworkCall(method, url, stopwatch.elapsedMilliseconds);
      Lumio.logCrash('Network Error: $e', StackTrace.current.toString());
      
      rethrow;
    }
  }

  /// Close the HTTP client
  void close() {
    _httpClient.close();
  }
}

/// HTTP interceptor for manual logging
class LumioHttpInterceptor {
  /// Wrap an HTTP response to automatically log it
  static Future<T> wrapResponse<T>(
    Future<T> Function() request,
    String method,
    String url,
  ) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final response = await request();
      stopwatch.stop();
      
      Lumio.logNetworkCall(method, url, stopwatch.elapsedMilliseconds);
      
      return response;
    } catch (e) {
      stopwatch.stop();
      
      Lumio.logNetworkCall(method, url, stopwatch.elapsedMilliseconds);
      Lumio.logCrash('Network Error: $e', StackTrace.current.toString());
      
      rethrow;
    }
  }

  /// Log a successful API response
  static void logResponse(String url, int statusCode, String body) {
    Lumio.logApiResponse(url, statusCode, body);
  }

  /// Log a network error
  static void logError(String url, String error) {
    Lumio.logCrash('Network Error for $url: $error', StackTrace.current.toString());
  }
}
