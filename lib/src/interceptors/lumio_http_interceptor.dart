import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/lumio_models.dart';
import '../utils/lumio_storage.dart';

/// HTTP interceptor for Lumio to automatically capture network calls
class LumioHttpInterceptor extends http.BaseClient {
  final http.Client _inner;
  final bool _enabled;

  LumioHttpInterceptor(this._inner, {bool enabled = true}) : _enabled = enabled;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (!_enabled) {
      return _inner.send(request);
    }

    final stopwatch = Stopwatch()..start();
    final startTime = DateTime.now();

    try {
      // Log the outgoing request
      await _logRequest(request);

      // Send the request
      final response = await _inner.send(request);

      // Calculate duration
      stopwatch.stop();
      final durationMs = stopwatch.elapsedMilliseconds;

      // Log the response
      await _logResponse(request, response, durationMs, startTime);

      return response;
    } catch (e) {
      stopwatch.stop();
      final durationMs = stopwatch.elapsedMilliseconds;

      // Log the error
      await _logError(request, e.toString(), durationMs, startTime);

      rethrow;
    }
  }

  /// Log outgoing request
  Future<void> _logRequest(http.BaseRequest request) async {
    try {
      final networkCall = NetworkCallLog(
        method: request.method,
        url: request.url.toString(),
        durationMs: 0, // Will be updated after response
        timestamp: DateTime.now(),
      );

      await LumioStorage.addNetworkCall(networkCall);
    } catch (e) {
      // Silently fail to avoid breaking the app
    }
  }

  /// Log incoming response
  Future<void> _logResponse(
    http.BaseRequest request,
    http.StreamedResponse response,
    int durationMs,
    DateTime startTime,
  ) async {
    try {
      // Read response body
      final responseBytes = await response.stream.toBytes();
      final responseBody = String.fromCharCodes(responseBytes);

      // Create a new response with the same bytes
      final newResponse = http.Response.fromStream(response);
      final responseWithBody = http.Response(
        responseBody,
        response.statusCode,
        headers: response.headers,
        request: request,
      );

      // Log API response
      final apiResponse = ApiResponseLog(
        url: request.url.toString(),
        statusCode: response.statusCode,
        body: responseBody,
        timestamp: startTime,
      );

      await LumioStorage.addApiResponse(apiResponse);

      // Update network call with duration
      final networkCall = NetworkCallLog(
        method: request.method,
        url: request.url.toString(),
        durationMs: durationMs,
        timestamp: startTime,
      );

      await LumioStorage.addNetworkCall(networkCall);
    } catch (e) {
      // Silently fail to avoid breaking the app
    }
  }

  /// Log error
  Future<void> _logError(
    http.BaseRequest request,
    String error,
    int durationMs,
    DateTime startTime,
  ) async {
    try {
      final networkCall = NetworkCallLog(
        method: request.method,
        url: request.url.toString(),
        durationMs: durationMs,
        timestamp: startTime,
      );

      await LumioStorage.addNetworkCall(networkCall);
    } catch (e) {
      // Silently fail to avoid breaking the app
    }
  }

  @override
  void close() {
    _inner.close();
  }
}

/// Extension to easily add Lumio interceptor to HTTP client
extension LumioHttpClientExtension on http.Client {
  /// Add Lumio HTTP interceptor
  LumioHttpInterceptor withLumioInterceptor({bool enabled = true}) {
    return LumioHttpInterceptor(this, enabled: enabled);
  }
}

/// Global HTTP client with Lumio interceptor
class LumioHttpClient {
  static http.Client? _client;

  /// Get HTTP client with Lumio interceptor
  static http.Client get client {
    _client ??= http.Client().withLumioInterceptor();
    return _client!;
  }

  /// Dispose the client
  static void dispose() {
    _client?.close();
    _client = null;
  }
}
