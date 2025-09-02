import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'lumio_method_channel.dart';

abstract class LumioPlatform extends PlatformInterface {
  /// Constructs a LumioPlatform.
  LumioPlatform() : super(token: _token);

  static final Object _token = Object();

  static LumioPlatform _instance = MethodChannelLumio();

  /// The default instance of [LumioPlatform] to use.
  ///
  /// Defaults to [MethodChannelLumio].
  static LumioPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [LumioPlatform] when
  /// they register themselves.
  static set instance(LumioPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// Log HTTP request for inspection
  Future<void> logHttpRequest(String method, String url, Map<String, String>? headers, String? body) {
    throw UnimplementedError('logHttpRequest() has not been implemented.');
  }

  /// Log HTTP response for inspection
  Future<void> logHttpResponse(String url, int statusCode, String body, Map<String, String>? headers, int? durationMs) {
    throw UnimplementedError('logHttpResponse() has not been implemented.');
  }

  /// Log crash with error message and stack trace
  Future<void> logCrash(String error, String stackTrace) {
    throw UnimplementedError('logCrash() has not been implemented.');
  }

  /// Log ANR (Application Not Responding) event
  Future<void> logAnr(String message) {
    throw UnimplementedError('logAnr() has not been implemented.');
  }

  /// Initialize crash monitoring
  Future<void> initializeCrashMonitoring() {
    throw UnimplementedError('initializeCrashMonitoring() has not been implemented.');
  }

  /// Initialize ANR monitoring (Android only)
  Future<void> initializeAnrMonitoring() {
    throw UnimplementedError('initializeAnrMonitoring() has not been implemented.');
  }
}
