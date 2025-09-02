package com.apppulse.app_pulse

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.text.SimpleDateFormat
import java.util.*
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit

/** AppPulsePlugin */
class AppPulsePlugin: FlutterPlugin, MethodCallHandler {
  companion object {
    private const val TAG = "AppPulse"
    private const val CHANNEL_NAME = "app_pulse"
  }

  private lateinit var channel: MethodChannel
  private lateinit var context: Context
  private var anrWatchdog: ANRWatchdog? = null
  private var crashHandler: Thread.UncaughtExceptionHandler? = null
  private val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS", Locale.getDefault())

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      "logApiResponse" -> {
        logApiResponse(call, result)
      }
      "logNetworkCall" -> {
        logNetworkCall(call, result)
      }
      "logCrash" -> {
        logCrash(call, result)
      }
      "logAnr" -> {
        logAnr(call, result)
      }
      "initializeCrashMonitoring" -> {
        initializeCrashMonitoring(result)
      }
      "initializeAnrMonitoring" -> {
        initializeAnrMonitoring(result)
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  private fun logApiResponse(call: MethodCall, result: Result) {
    try {
      val url = call.argument<String>("url") ?: ""
      val statusCode = call.argument<Int>("statusCode") ?: 0
      val body = call.argument<String>("body") ?: ""
      val timestamp = dateFormat.format(Date())
      
      Log.d(TAG, "API Response [$timestamp]: $url - Status: $statusCode")
      Log.d(TAG, "Response Body: ${body.take(500)}${if (body.length > 500) "..." else ""}")
      
      result.success(null)
    } catch (e: Exception) {
      Log.e(TAG, "Error logging API response: ${e.message}")
      result.error("LOG_ERROR", "Failed to log API response", e.message)
    }
  }

  private fun logNetworkCall(call: MethodCall, result: Result) {
    try {
      val method = call.argument<String>("method") ?: ""
      val url = call.argument<String>("url") ?: ""
      val durationMs = call.argument<Int>("durationMs") ?: 0
      val timestamp = dateFormat.format(Date())
      
      Log.d(TAG, "Network Call [$timestamp]: $method $url - Duration: ${durationMs}ms")
      
      result.success(null)
    } catch (e: Exception) {
      Log.e(TAG, "Error logging network call: ${e.message}")
      result.error("LOG_ERROR", "Failed to log network call", e.message)
    }
  }

  private fun logCrash(call: MethodCall, result: Result) {
    try {
      val error = call.argument<String>("error") ?: ""
      val stackTrace = call.argument<String>("stackTrace") ?: ""
      val timestamp = dateFormat.format(Date())
      
      Log.e(TAG, "Crash [$timestamp]: $error")
      Log.e(TAG, "Stack Trace: $stackTrace")
      
      result.success(null)
    } catch (e: Exception) {
      Log.e(TAG, "Error logging crash: ${e.message}")
      result.error("LOG_ERROR", "Failed to log crash", e.message)
    }
  }

  private fun logAnr(call: MethodCall, result: Result) {
    try {
      val message = call.argument<String>("message") ?: ""
      val timestamp = dateFormat.format(Date())
      
      Log.w(TAG, "ANR [$timestamp]: $message")
      
      result.success(null)
    } catch (e: Exception) {
      Log.e(TAG, "Error logging ANR: ${e.message}")
      result.error("LOG_ERROR", "Failed to log ANR", e.message)
    }
  }

  private fun initializeCrashMonitoring(result: Result) {
    try {
      if (crashHandler == null) {
        val defaultHandler = Thread.getDefaultUncaughtExceptionHandler()
        crashHandler = Thread.UncaughtExceptionHandler { thread, exception ->
          val timestamp = dateFormat.format(Date())
          Log.e(TAG, "Uncaught Exception [$timestamp] in thread ${thread.name}: ${exception.message}")
          Log.e(TAG, "Exception Stack Trace: ${Log.getStackTraceString(exception)}")
          
          // Call the default handler to maintain normal crash behavior
          defaultHandler?.uncaughtException(thread, exception)
        }
        Thread.setDefaultUncaughtExceptionHandler(crashHandler)
        Log.d(TAG, "Crash monitoring initialized")
      }
      result.success(null)
    } catch (e: Exception) {
      Log.e(TAG, "Error initializing crash monitoring: ${e.message}")
      result.error("INIT_ERROR", "Failed to initialize crash monitoring", e.message)
    }
  }

  private fun initializeAnrMonitoring(result: Result) {
    try {
      if (anrWatchdog == null) {
        anrWatchdog = ANRWatchdog()
        anrWatchdog?.start()
        Log.d(TAG, "ANR monitoring initialized")
      }
      result.success(null)
    } catch (e: Exception) {
      Log.e(TAG, "Error initializing ANR monitoring: ${e.message}")
      result.error("INIT_ERROR", "Failed to initialize ANR monitoring", e.message)
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    anrWatchdog?.stop()
    anrWatchdog = null
  }

  /**
   * Simple ANR Watchdog implementation
   * Monitors the main thread for ANR conditions
   */
  private class ANRWatchdog {
    private val executor = Executors.newSingleThreadExecutor()
    private val handler = Handler(Looper.getMainLooper())
    private var isRunning = false
    private val timeout = 5000L // 5 seconds
    
    @Volatile
    private var tick = 0L
    
    fun start() {
      if (isRunning) return
      isRunning = true
      
      executor.execute {
        while (isRunning) {
          val currentTick = tick
          
          // Post a runnable to main thread
          handler.post { tick = System.currentTimeMillis() }
          
          // Wait for timeout
          Thread.sleep(timeout)
          
          // Check if main thread responded
          if (tick == currentTick && isRunning) {
            val timestamp = SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS", Locale.getDefault()).format(Date())
            Log.w(TAG, "ANR Detected [$timestamp]: Main thread blocked for more than ${timeout}ms")
          }
        }
      }
    }
    
    fun stop() {
      isRunning = false
      executor.shutdown()
      try {
        if (!executor.awaitTermination(1, TimeUnit.SECONDS)) {
          executor.shutdownNow()
        }
      } catch (e: InterruptedException) {
        executor.shutdownNow()
        Thread.currentThread().interrupt()
      }
    }
  }
}
