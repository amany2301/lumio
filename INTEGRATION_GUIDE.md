# Lumio Integration Guide

## 🚀 Ultra-Simple Setup

### Step 1: Add Dependencies

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  lumio: ^0.0.1
  http: ^1.1.0
  dio: ^5.4.0  # Optional - for Dio support
```

### Step 2: Initialize (One Line!)

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:lumio/lumio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Lumio.initialize();  // 👈 That's it!

  runApp(MyApp());
}
```

### Step 3: HTTP Calls (Multiple Ways)

#### HTTP Package

##### Easy Way → Global Hook (Recommended)
**No code changes needed!** All HTTP calls are automatically logged:

```dart
import 'package:http/http.dart' as http;

// Your existing HTTP calls work automatically
final response = await http.get(Uri.parse('https://api.example.com/data'));
final response = await http.post(Uri.parse('https://api.example.com/data'), body: {'key': 'value'});
```

##### Manual Way → Explicit Client
Use Lumio's HTTP client for explicit logging:

```dart
import 'package:lumio/lumio.dart';

// Use Lumio's client explicitly
final response = await Lumio.httpClient.get(Uri.parse('https://api.example.com/data'));
```

#### Dio Package

##### Easy Way → Lumio Dio Client
Use Lumio's Dio client with automatic logging:

```dart
import 'package:lumio/lumio.dart';

// Use Lumio's Dio client
final response = await Lumio.dioClient.get('https://api.example.com/data');
final response = await Lumio.dioClient.post('https://api.example.com/data', data: {'key': 'value'});
```

##### Manual Way → Add Interceptor
Add Lumio interceptor to your existing Dio instance:

```dart
import 'package:dio/dio.dart';
import 'package:lumio/lumio.dart';

final dio = Dio();
dio.addLumioInterceptor(); // Add Lumio interceptor

// Now all calls through this Dio instance are logged
final response = await dio.get('https://api.example.com/data');
```

##### Auto Detection → Automatic Injection
**NEW!** Lumio automatically detects and injects interceptors into existing Dio instances:

```dart
import 'package:dio/dio.dart';
import 'package:lumio/lumio.dart';

// Just call Lumio.initialize() - it will auto-detect Dio usage
Lumio.initialize();

// Your existing Dio instances will be automatically monitored
final dio = Dio(); // This will be auto-detected and monitored
final response = await dio.get('https://api.example.com/data');

// Or manually register existing instances
final existingDio = Dio();
existingDio.registerWithLumio(); // Register for auto-monitoring
```

### Step 4: Access Debug UI (Optional)

```dart
// Add to your AppBar
AppBar(
  title: Text('My App'),
  actions: [
    IconButton(
      icon: Icon(Icons.bug_report),
      onPressed: () => Lumio.showDebugUI(context),
    ),
  ],
)
```

## ✅ Done!

That's it! Now you have:
- ✅ **Automatic network logging** (Global Hook)
- ✅ **Crash detection**
- ✅ **ANR monitoring**
- ✅ **Debug notification**
- ✅ **Comprehensive debug UI**

## 🎯 What Happens

1. **Debug Mode**: Notification appears automatically
2. **Network Calls**: Automatically logged (Global Hook) or when using `Lumio.httpClient`
3. **Crashes**: Automatically captured and logged
4. **Debug UI**: Tap notification or use `Lumio.showDebugUI(context)`

## 🔧 Advanced Options

If you need custom configuration:

```dart
await Lumio.initializeWithConfig(
  enableCrashMonitoring: true,
  enableAnrMonitoring: true,
  enableNotification: true,
  maxLogEntries: 1000,
);
```

## 📱 Platform Setup

### Android
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

### iOS
No setup required.

## 🚨 Troubleshooting

- **No notification**: Ensure running in debug mode
- **No logs**: Use `Lumio.httpClient` instead of regular `http.get`
- **Debug UI not opening**: Check that Lumio is initialized

## 🎉 Benefits

- **Zero Configuration**: Works out of the box
- **Debug Mode Only**: No production impact
- **One Line Setup**: `Lumio.initialize()`
- **Automatic Logging**: No manual intervention needed
- **Comprehensive UI**: All logs in one place
