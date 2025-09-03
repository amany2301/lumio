import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/lumio_models.dart';
import '../utils/lumio_storage.dart';

/// Dio interceptor for Lumio to automatically capture network calls
class LumioDioInterceptor extends Interceptor {
  final bool _enabled;

  LumioDioInterceptor({bool enabled = true}) : _enabled = enabled;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!_enabled) {
      handler.next(options);
      return;
    }

    // Log the outgoing request
    _logRequest(options);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!_enabled) {
      handler.next(response);
      return;
    }

    // Log the response
    _logResponse(response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!_enabled) {
      handler.next(err);
      return;
    }

    // Log the error
    _logError(err);
    handler.next(err);
  }

  /// Log outgoing request
  void _logRequest(RequestOptions options) {
    try {
      final networkCall = NetworkCallLog(
        method: options.method,
        url: options.uri.toString(),
        durationMs: 0, // Will be calculated after response
        timestamp: DateTime.now(),
      );

      // Store the request start time for duration calculation
      options.extra['lumio_start_time'] = DateTime.now();
      
      // Note: We'll log the network call after response for accurate duration
    } catch (e) {
      debugPrint('Lumio: Failed to log Dio request: $e');
    }
  }

  /// Log incoming response
  void _logResponse(Response response) {
    try {
      final startTime = response.requestOptions.extra['lumio_start_time'] as DateTime?;
      final durationMs = startTime != null 
          ? DateTime.now().difference(startTime).inMilliseconds 
          : 0;

      // Log API response
      final apiResponse = ApiResponseLog(
        url: response.requestOptions.uri.toString(),
        statusCode: response.statusCode ?? 0,
        body: _formatResponseBody(response.data),
        timestamp: startTime ?? DateTime.now(),
      );

      LumioStorage.addApiResponse(apiResponse);

      // Log network call with duration
      final networkCall = NetworkCallLog(
        method: response.requestOptions.method,
        url: response.requestOptions.uri.toString(),
        durationMs: durationMs,
        timestamp: startTime ?? DateTime.now(),
      );

      LumioStorage.addNetworkCall(networkCall);
    } catch (e) {
      debugPrint('Lumio: Failed to log Dio response: $e');
    }
  }

  /// Log error
  void _logError(DioException err) {
    try {
      final startTime = err.requestOptions.extra['lumio_start_time'] as DateTime?;
      final durationMs = startTime != null 
          ? DateTime.now().difference(startTime).inMilliseconds 
          : 0;

      // Log network call with error
      final networkCall = NetworkCallLog(
        method: err.requestOptions.method,
        url: err.requestOptions.uri.toString(),
        durationMs: durationMs,
        timestamp: startTime ?? DateTime.now(),
      );

      LumioStorage.addNetworkCall(networkCall);

      // Log crash if it's a network error
      if (err.type == DioExceptionType.connectionError || 
          err.type == DioExceptionType.connectionTimeout) {
        LumioStorage.addCrash(CrashLog(
          error: 'Dio Network Error: ${err.message}',
          stackTrace: err.stackTrace?.toString() ?? 'No stack trace available',
          timestamp: DateTime.now(),
        ));
      }
    } catch (e) {
      debugPrint('Lumio: Failed to log Dio error: $e');
    }
  }

  /// Format response body for logging
  String _formatResponseBody(dynamic data) {
    if (data == null) return '';
    
    try {
      if (data is String) return data;
      if (data is Map || data is List) {
        return data.toString();
      }
      return data.toString();
    } catch (e) {
      return 'Error formatting response body: $e';
    }
  }
}

/// Extension to easily add Lumio interceptor to Dio
extension LumioDioExtension on Dio {
  /// Add Lumio Dio interceptor
  void addLumioInterceptor({bool enabled = true}) {
    interceptors.add(LumioDioInterceptor(enabled: enabled));
  }
}

/// Global Dio instance with Lumio interceptor
class LumioDio {
  static Dio? _dio;

  /// Get Dio instance with Lumio interceptor
  static Dio get dio {
    _dio ??= Dio()..addLumioInterceptor();
    return _dio!;
  }

  /// Create a new Dio instance with Lumio interceptor
  static Dio create() {
    return Dio()..addLumioInterceptor();
  }

  /// Dispose the Dio instance
  static void dispose() {
    _dio?.close();
    _dio = null;
  }
}
