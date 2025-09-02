import Flutter
import UIKit
import Foundation

public class LumioPlugin: NSObject, FlutterPlugin {
    private static let TAG = "Lumio"
    private static let CHANNEL_NAME = "lumio"
    
    private var crashMonitoringInitialized = false
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: CHANNEL_NAME, binaryMessenger: registrar.messenger())
        let instance = LumioPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
            
        case "logApiResponse":
            logApiResponse(call: call, result: result)
            
        case "logNetworkCall":
            logNetworkCall(call: call, result: result)
            
        case "logCrash":
            logCrash(call: call, result: result)
            
        case "logAnr":
            logAnr(call: call, result: result)
            
        case "initializeCrashMonitoring":
            initializeCrashMonitoring(result: result)
            
        case "initializeAnrMonitoring":
            // ANR monitoring is Android-specific, but we'll acknowledge the call
            result(nil)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func logApiResponse(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let url = args["url"] as? String,
              let statusCode = args["statusCode"] as? Int,
              let body = args["body"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments for logApiResponse", details: nil))
            return
        }
        
        let timestamp = dateFormatter.string(from: Date())
        let truncatedBody = body.count > 500 ? String(body.prefix(500)) + "..." : body
        
        print("[\(Self.TAG)] API Response [\(timestamp)]: \(url) - Status: \(statusCode)")
        print("[\(Self.TAG)] Response Body: \(truncatedBody)")
        
        result(nil)
    }
    
    private func logNetworkCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let method = args["method"] as? String,
              let url = args["url"] as? String,
              let durationMs = args["durationMs"] as? Int else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments for logNetworkCall", details: nil))
            return
        }
        
        let timestamp = dateFormatter.string(from: Date())
        print("[\(Self.TAG)] Network Call [\(timestamp)]: \(method) \(url) - Duration: \(durationMs)ms")
        
        result(nil)
    }
    
    private func logCrash(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let error = args["error"] as? String,
              let stackTrace = args["stackTrace"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments for logCrash", details: nil))
            return
        }
        
        let timestamp = dateFormatter.string(from: Date())
        print("[\(Self.TAG)] Crash [\(timestamp)]: \(error)")
        print("[\(Self.TAG)] Stack Trace: \(stackTrace)")
        
        result(nil)
    }
    
    private func logAnr(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let message = args["message"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments for logAnr", details: nil))
            return
        }
        
        let timestamp = dateFormatter.string(from: Date())
        print("[\(Self.TAG)] ANR [\(timestamp)]: \(message)")
        
        result(nil)
    }
    
    private func initializeCrashMonitoring(result: @escaping FlutterResult) {
        if crashMonitoringInitialized {
            result(nil)
            return
        }
        
        // Set up uncaught exception handler
        NSSetUncaughtExceptionHandler { exception in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            let timestamp = formatter.string(from: Date())
            print("[Lumio] Uncaught Exception [\(timestamp)]: \(exception.name.rawValue)")
            print("[Lumio] Exception Reason: \(exception.reason ?? "No reason provided")")
            print("[Lumio] Exception Stack: \(exception.callStackSymbols.joined(separator: "\n"))")
        }
        
        // Set up signal handlers for crashes - using global functions to avoid closure capture issues
        signal(SIGABRT, handleSignalABRT)
        signal(SIGILL, handleSignalILL)
        signal(SIGSEGV, handleSignalSEGV)
        signal(SIGFPE, handleSignalFPE)
        signal(SIGBUS, handleSignalBUS)
        
        crashMonitoringInitialized = true
        print("[\(Self.TAG)] Crash monitoring initialized")
        result(nil)
    }
}

// Global signal handler functions to avoid closure capture issues
func handleSignalABRT(signal: Int32) {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    let timestamp = formatter.string(from: Date())
    print("[Lumio] Signal [\(timestamp)]: SIGABRT received")
}

func handleSignalILL(signal: Int32) {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    let timestamp = formatter.string(from: Date())
    print("[Lumio] Signal [\(timestamp)]: SIGILL received")
}

func handleSignalSEGV(signal: Int32) {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    let timestamp = formatter.string(from: Date())
    print("[Lumio] Signal [\(timestamp)]: SIGSEGV received")
}

func handleSignalFPE(signal: Int32) {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    let timestamp = formatter.string(from: Date())
    print("[Lumio] Signal [\(timestamp)]: SIGFPE received")
}

func handleSignalBUS(signal: Int32) {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    let timestamp = formatter.string(from: Date())
    print("[Lumio] Signal [\(timestamp)]: SIGBUS received")
}
