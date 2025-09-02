import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'lumio_platform_interface.dart';

/// An implementation of [LumioPlatform] that uses method channels.
class MethodChannelLumio extends LumioPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('lumio');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> logApiResponse(String url, int statusCode, String body) async {
    await methodChannel.invokeMethod('logApiResponse', {
      'url': url,
      'statusCode': statusCode,
      'body': body,
    });
  }

  @override
  Future<void> logNetworkCall(String method, String url, int durationMs) async {
    await methodChannel.invokeMethod('logNetworkCall', {
      'method': method,
      'url': url,
      'durationMs': durationMs,
    });
  }

  @override
  Future<void> logCrash(String error, String stackTrace) async {
    await methodChannel.invokeMethod('logCrash', {
      'error': error,
      'stackTrace': stackTrace,
    });
  }

  @override
  Future<void> logAnr(String message) async {
    await methodChannel.invokeMethod('logAnr', {
      'message': message,
    });
  }

  @override
  Future<void> initializeCrashMonitoring() async {
    await methodChannel.invokeMethod('initializeCrashMonitoring');
  }

  @override
  Future<void> initializeAnrMonitoring() async {
    await methodChannel.invokeMethod('initializeAnrMonitoring');
  }
}
