
import 'dart:convert';

/// Represents a complete network request/response cycle
class NetworkCall {
  final String id;
  final String method;
  final String url;
  final Map<String, String> requestHeaders;
  final String? requestBody;
  final DateTime requestTime;
  
  // Response data
  int? statusCode;
  Map<String, String>? responseHeaders;
  String? responseBody;
  DateTime? responseTime;
  String? error;
  
  // Metadata
  int? duration;
  int? requestSize;
  int? responseSize;
  bool isCompleted;

  NetworkCall({
    required this.id,
    required this.method,
    required this.url,
    required this.requestHeaders,
    this.requestBody,
    required this.requestTime,
    this.statusCode,
    this.responseHeaders,
    this.responseBody,
    this.responseTime,
    this.error,
    this.duration,
    this.requestSize,
    this.responseSize,
    this.isCompleted = false,
  });

  /// Create a copy with updated response data
  NetworkCall copyWithResponse({
    int? statusCode,
    Map<String, String>? responseHeaders,
    String? responseBody,
    DateTime? responseTime,
    String? error,
  }) {
    final now = responseTime ?? DateTime.now();
    return NetworkCall(
      id: id,
      method: method,
      url: url,
      requestHeaders: requestHeaders,
      requestBody: requestBody,
      requestTime: requestTime,
      statusCode: statusCode ?? this.statusCode,
      responseHeaders: responseHeaders ?? this.responseHeaders,
      responseBody: responseBody ?? this.responseBody,
      responseTime: now,
      error: error ?? this.error,
      duration: now.difference(requestTime).inMilliseconds,
      requestSize: requestSize ?? (requestBody?.length ?? 0),
      responseSize: responseSize ?? (responseBody?.length ?? 0),
      isCompleted: true,
    );
  }

  /// Get status text for the HTTP status code
  String get statusText {
    if (statusCode == null) return 'Pending';
    switch (statusCode!) {
      case 200: return 'OK';
      case 201: return 'Created';
      case 204: return 'No Content';
      case 400: return 'Bad Request';
      case 401: return 'Unauthorized';
      case 403: return 'Forbidden';
      case 404: return 'Not Found';
      case 500: return 'Internal Server Error';
      case 502: return 'Bad Gateway';
      case 503: return 'Service Unavailable';
      default: return 'HTTP $statusCode';
    }
  }

  /// Check if the request was successful
  bool get isSuccess => statusCode != null && statusCode! >= 200 && statusCode! < 300;

  /// Check if there was an error
  bool get hasError => error != null || (statusCode != null && statusCode! >= 400);

  /// Get formatted request body (JSON formatted if possible)
  String get formattedRequestBody {
    if (requestBody == null || requestBody!.isEmpty) return '';
    try {
      final dynamic jsonObject = jsonDecode(requestBody!);
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(jsonObject);
    } catch (e) {
      return requestBody!;
    }
  }

  /// Get formatted response body (JSON formatted if possible)
  String get formattedResponseBody {
    if (responseBody == null || responseBody!.isEmpty) return '';
    try {
      final dynamic jsonObject = jsonDecode(responseBody!);
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(jsonObject);
    } catch (e) {
      return responseBody!;
    }
  }

  /// Generate cURL command for this request
  String get curlCommand {
    final buffer = StringBuffer();
    buffer.write('curl -X $method');
    
    // Add headers
    requestHeaders.forEach((key, value) {
      buffer.write(' \\\n  -H "$key: $value"');
    });
    
    // Add body for POST/PUT/PATCH requests
    if (requestBody != null && requestBody!.isNotEmpty && 
        ['POST', 'PUT', 'PATCH'].contains(method.toUpperCase())) {
      final escapedBody = requestBody!.replaceAll('"', '\\"');
      buffer.write(' \\\n  -d "$escapedBody"');
    }
    
    // Add URL
    buffer.write(' \\\n  "$url"');
    
    return buffer.toString();
  }

  /// Convert to JSON for export
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'method': method,
      'url': url,
      'requestHeaders': requestHeaders,
      'requestBody': requestBody,
      'requestTime': requestTime.toIso8601String(),
      'statusCode': statusCode,
      'responseHeaders': responseHeaders,
      'responseBody': responseBody,
      'responseTime': responseTime?.toIso8601String(),
      'error': error,
      'duration': duration,
      'requestSize': requestSize,
      'responseSize': responseSize,
      'isCompleted': isCompleted,
    };
  }
}

/// Network statistics and metrics
class NetworkStats {
  final int totalRequests;
  final int successfulRequests;
  final int failedRequests;
  final int pendingRequests;
  final double averageResponseTime;
  final int totalDataTransferred;

  NetworkStats({
    required this.totalRequests,
    required this.successfulRequests,
    required this.failedRequests,
    required this.pendingRequests,
    required this.averageResponseTime,
    required this.totalDataTransferred,
  });

  double get successRate => totalRequests > 0 ? (successfulRequests / totalRequests) * 100 : 0;
  double get failureRate => totalRequests > 0 ? (failedRequests / totalRequests) * 100 : 0;
}
