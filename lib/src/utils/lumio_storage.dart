import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lumio_models.dart';

/// Optimized storage service for Lumio with batch operations and memory management
class LumioStorage {
  static const String _networkCallsKey = 'lumio_network_calls';
  static const String _apiResponsesKey = 'lumio_api_responses';
  static const String _crashesKey = 'lumio_crashes';
  static const String _anrsKey = 'lumio_anrs';
  static const String _maxLogsKey = 'lumio_max_logs';
  
  static SharedPreferences? _prefs;
  static int _maxLogs = 1000;
  static final Map<String, List<dynamic>> _cache = {};
  static Timer? _batchTimer;
  static final List<Map<String, dynamic>> _pendingWrites = [];
  static bool _isInitialized = false;

  /// Initialize storage with optimized settings
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    _prefs = await SharedPreferences.getInstance();
    _maxLogs = _prefs?.getInt(_maxLogsKey) ?? 1000;
    
    // Pre-load cache for better performance
    await _loadCache();
    
    // Start batch processing
    _startBatchProcessing();
    
    _isInitialized = true;
  }

  /// Pre-load data into cache for faster access
  static Future<void> _loadCache() async {
    if (_prefs == null) return;
    
    try {
      _cache[_networkCallsKey] = _prefs!.getStringList(_networkCallsKey)?.map((e) => jsonDecode(e)).toList() ?? [];
      _cache[_apiResponsesKey] = _prefs!.getStringList(_apiResponsesKey)?.map((e) => jsonDecode(e)).toList() ?? [];
      _cache[_crashesKey] = _prefs!.getStringList(_crashesKey)?.map((e) => jsonDecode(e)).toList() ?? [];
      _cache[_anrsKey] = _prefs!.getStringList(_anrsKey)?.map((e) => jsonDecode(e)).toList() ?? [];
    } catch (e) {
      // Clear corrupted cache
      _cache.clear();
    }
  }

  /// Start batch processing for better performance
  static void _startBatchProcessing() {
    _batchTimer?.cancel();
    _batchTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _processBatchWrites();
    });
  }

  /// Process batch writes to reduce I/O operations
  static Future<void> _processBatchWrites() async {
    if (_pendingWrites.isEmpty) return;
    
    final batch = List<Map<String, dynamic>>.from(_pendingWrites);
    _pendingWrites.clear();
    
    try {
      for (final write in batch) {
        await _writeToStorage(write['key'], write['data']);
      }
    } catch (e) {
      // Re-add failed writes
      _pendingWrites.addAll(batch);
    }
  }

  /// Optimized write operation with batching
  static Future<void> _writeToStorage(String key, List<dynamic> data) async {
    if (_prefs == null) return;
    
    final stringList = data.map((e) => jsonEncode(e)).toList();
    await _prefs!.setStringList(key, stringList);
  }

  /// Add network call with optimized storage
  static Future<void> addNetworkCall(NetworkCallLog log) async {
    if (!_isInitialized) await initialize();
    
    _addToCache(_networkCallsKey, log.toJson());
    _scheduleBatchWrite(_networkCallsKey, _cache[_networkCallsKey]!);
  }

  /// Add API response with optimized storage
  static Future<void> addApiResponse(ApiResponseLog log) async {
    if (!_isInitialized) await initialize();
    
    _addToCache(_apiResponsesKey, log.toJson());
    _scheduleBatchWrite(_apiResponsesKey, _cache[_apiResponsesKey]!);
  }

  /// Add crash with optimized storage
  static Future<void> addCrash(CrashLog log) async {
    if (!_isInitialized) await initialize();
    
    _addToCache(_crashesKey, log.toJson());
    _scheduleBatchWrite(_crashesKey, _cache[_crashesKey]!);
  }

  /// Add ANR with optimized storage
  static Future<void> addAnr(AnrLog log) async {
    if (!_isInitialized) await initialize();
    
    _addToCache(_anrsKey, log.toJson());
    _scheduleBatchWrite(_anrsKey, _cache[_anrsKey]!);
  }

  /// Add to cache with size management
  static void _addToCache(String key, Map<String, dynamic> data) {
    if (!_cache.containsKey(key)) {
      _cache[key] = [];
    }
    
    _cache[key]!.add(data);
    
    // Maintain max size
    if (_cache[key]!.length > _maxLogs) {
      _cache[key] = _cache[key]!.skip(_cache[key]!.length - _maxLogs).toList();
    }
  }

  /// Schedule batch write operation
  static void _scheduleBatchWrite(String key, List<dynamic> data) {
    _pendingWrites.add({'key': key, 'data': data});
  }

  /// Get network calls from cache
  static Future<List<NetworkCallLog>> getNetworkCalls() async {
    if (!_isInitialized) await initialize();
    
    return _cache[_networkCallsKey]?.map((e) => NetworkCallLog.fromJson(e)).toList() ?? [];
  }

  /// Get API responses from cache
  static Future<List<ApiResponseLog>> getApiResponses() async {
    if (!_isInitialized) await initialize();
    
    return _cache[_apiResponsesKey]?.map((e) => ApiResponseLog.fromJson(e)).toList() ?? [];
  }

  /// Get crashes from cache
  static Future<List<CrashLog>> getCrashes() async {
    if (!_isInitialized) await initialize();
    
    return _cache[_crashesKey]?.map((e) => CrashLog.fromJson(e)).toList() ?? [];
  }

  /// Get ANRs from cache
  static Future<List<AnrLog>> getAnrs() async {
    if (!_isInitialized) await initialize();
    
    return _cache[_anrsKey]?.map((e) => AnrLog.fromJson(e)).toList() ?? [];
  }

  /// Clear all logs with optimized operation
  static Future<void> clearAllLogs() async {
    if (!_isInitialized) await initialize();
    
    _cache.clear();
    _pendingWrites.clear();
    
    if (_prefs != null) {
      await Future.wait([
        _prefs!.remove(_networkCallsKey),
        _prefs!.remove(_apiResponsesKey),
        _prefs!.remove(_crashesKey),
        _prefs!.remove(_anrsKey),
      ]);
    }
  }

  /// Set max logs with validation
  static Future<void> setMaxLogs(int maxLogs) async {
    if (!_isInitialized) await initialize();
    
    _maxLogs = maxLogs.clamp(100, 10000); // Reasonable limits
    
    if (_prefs != null) {
      await _prefs!.setInt(_maxLogsKey, _maxLogs);
    }
    
    // Trim existing data to new limit
    for (final key in _cache.keys) {
      if (_cache[key]!.length > _maxLogs) {
        _cache[key] = _cache[key]!.skip(_cache[key]!.length - _maxLogs).toList();
      }
    }
  }

  /// Get log counts efficiently
  static Future<Map<String, int>> getLogCounts() async {
    if (!_isInitialized) await initialize();
    
    return {
      'networkCalls': _cache[_networkCallsKey]?.length ?? 0,
      'apiResponses': _cache[_apiResponsesKey]?.length ?? 0,
      'crashes': _cache[_crashesKey]?.length ?? 0,
      'anrs': _cache[_anrsKey]?.length ?? 0,
    };
  }

  /// Export all data for external use
  static Future<Map<String, dynamic>> exportAllData() async {
    if (!_isInitialized) await initialize();
    
    try {
      final networkCalls = await getNetworkCalls();
      final apiResponses = await getApiResponses();
      final crashes = await getCrashes();
      final anrs = await getAnrs();

      return {
        'exportTimestamp': DateTime.now().toIso8601String(),
        'maxLogs': _maxLogs,
        'isInitialized': _isInitialized,
        'networkCalls': networkCalls.map((log) => log.toJson()).toList(),
        'apiResponses': apiResponses.map((log) => log.toJson()).toList(),
        'crashes': crashes.map((log) => log.toJson()).toList(),
        'anrs': anrs.map((log) => log.toJson()).toList(),
      };
    } catch (e) {
      debugPrint('Lumio: Export failed: $e');
      rethrow;
    }
  }

  /// Dispose resources
  static void dispose() {
    _batchTimer?.cancel();
    _processBatchWrites(); // Process any remaining writes
    _cache.clear();
    _pendingWrites.clear();
    _isInitialized = false;
  }

  /// Get max logs setting
  static int get maxLogs => _maxLogs;
  
  /// Check if initialized
  static bool get isInitialized => _isInitialized;
}
