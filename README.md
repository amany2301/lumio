# Lumio - Flutter Debugging Framework

[![pub package](https://img.shields.io/pub/v/lumio.svg)](https://pub.dev/packages/lumio)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)

Lumio is an on-device debugging framework for Flutter applications, inspired by [Android Pluto](https://github.com/androidPluto/pluto.git). It helps intercept network calls, capture crashes & ANRs, and provides a comprehensive debugging interface accessible via a persistent notification in debug mode.

## Features

- 🔍 **Network Monitoring**: Automatically intercept and log HTTP requests/responses
- 🚨 **Crash Detection**: Capture and log application crashes with stack traces
- ⏱️ **ANR Monitoring**: Detect Application Not Responding events (Android)
- 📱 **Debug UI**: Beautiful interface to inspect all logs with search and filtering
- 🔔 **Notification Access**: Persistent notification in debug mode for quick access
- 💾 **Local Storage**: Store logs locally using SharedPreferences
- 🔄 **Real-time Updates**: Live notification updates with log counts

## Screenshots

*Screenshots will be added here showing the notification and debug UI*

## Installation

### 1. Add Dependencies

Add Lumio to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  lumio: ^0.0.1
  http: ^1.1.0  # Required for HTTP interceptor
```

### 2. Initialize Lumio

Just one line in your `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:lumio/lumio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Lumio.initialize();  // 👈 One line only

  runApp(MyApp());
}
```

**That's it!** Lumio will automatically:
- Enable crash monitoring
- Enable ANR monitoring (Android)
- Show notification in debug mode
- Set up HTTP interception
- Configure local storage

### 3. HTTP Calls (Multiple Ways)

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

// Or wrap your existing HTTP client
final client = http.Client().withLumioInterceptor();
final response = await client.get(Uri.parse('https://api.example.com/data'));
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

## Usage

### Basic Setup

```dart
import 'package:flutter/material.dart';
import 'package:lumio/lumio.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // No initialization needed in widget - Lumio is already initialized in main()

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My App'),
        actions: [
          // Add a button to manually open debug UI
          IconButton(
            icon: Icon(Icons.bug_report),
            onPressed: () => Lumio.showDebugUI(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _makeApiCall,
              child: Text('Make API Call'),
            ),
            ElevatedButton(
              onPressed: _triggerCrash,
              child: Text('Trigger Crash'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makeApiCall() async {
    try {
      // This will be automatically logged by Lumio
      final response = await Lumio.httpClient.get('https://jsonplaceholder.typicode.com/posts/1');
      print('Response: ${response.body}');
    } catch (e) {
      print('Error: $e');
    }
  }

  void _triggerCrash() {
    // This will be automatically logged by Lumio
    throw Exception('Test crash for debugging');
  }
}
```

### Manual Logging

You can also manually log events:

```dart
// Log API responses
Lumio.logApiResponse('https://api.example.com/data', 200, '{"success": true}');

// Log network calls
Lumio.logNetworkCall('GET', 'https://api.example.com/data', 150);

// Log crashes
Lumio.logCrash('Network timeout', 'Stack trace here...');

// Log ANRs (Android only)
Lumio.logAnr('Main thread blocked for 5 seconds');
```

### Accessing Debug UI

The debug UI can be accessed in several ways:

1. **Notification**: Tap the persistent Lumio notification in debug mode
2. **Manual**: Call `Lumio.showDebugUI(context)` from anywhere in your app
3. **Programmatic**: Use the provided methods to access logs

```dart
// Show debug UI
Lumio.showDebugUI(context);

// Export all data
final data = await Lumio.exportAllData();

// Clear all logs
await Lumio.clearAllLogs();
```

## Debug Interface

When you tap the Lumio notification or call `Lumio.showDebugUI(context)`, you'll see a comprehensive interface with four tabs:

### 1. Network Calls
- Shows all HTTP requests with method, URL, duration, and timestamp
- Expandable cards with detailed information
- Color-coded by HTTP method

### 2. API Responses
- Displays all API responses with status codes
- Shows response bodies in formatted JSON
- Status codes are color-coded (green for success, red for errors)

### 3. Crashes
- Lists all captured crashes with error messages
- Shows full stack traces
- Red-themed cards for easy identification

### 4. ANRs
- Displays Application Not Responding events
- Shows timing information
- Orange-themed cards for identification

## Configuration

### Simple Initialization (Recommended)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Lumio.initialize();  // 👈 One line with sensible defaults
  runApp(MyApp());
}
```

### Custom Configuration (Advanced)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Lumio.initializeWithConfig(
    enableCrashMonitoring: true,    // Enable automatic crash detection
    enableAnrMonitoring: true,      // Enable ANR detection (Android only)
    enableNotification: true,       // Show persistent notification in debug mode
    maxLogEntries: 1000,           // Maximum number of logs to keep
  );
  
  runApp(MyApp());
}
```

### HTTP Interceptor Options

```dart
// Enable/disable interceptor
final client = http.Client().withLumioInterceptor(enabled: true);

// Use global client
final response = await Lumio.httpClient.get('https://api.example.com/data');
```

## Platform Support

- ✅ **Android**: Full support including ANR monitoring
- ✅ **iOS**: Full support (ANR monitoring not available)
- ✅ **Web**: Basic support (limited platform-specific features)
- ✅ **Desktop**: Basic support

## Debug Mode Only

Lumio is designed to work only in debug mode. The notification and most features are automatically disabled in release builds to ensure no performance impact on production apps.

## Permissions

Lumio requires the following permissions:

### Android
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

### iOS
No additional permissions required.

## Troubleshooting

### Notification Not Showing
- Ensure you're running in debug mode
- Check that notification permissions are granted
- Verify that `enableNotification: true` is set in initialization

### HTTP Interceptor Not Working
- Make sure you're using `Lumio.httpClient` or wrapping your client with `withLumioInterceptor()`
- Check that the HTTP package is properly imported

### Debug UI Not Opening
- Ensure Lumio is initialized before calling `showDebugUI()`
- Check that you're passing a valid BuildContext

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by [Android Pluto](https://github.com/androidPluto/pluto.git)
- Built with Flutter and Dart

## Support

- 📧 Email: support@lumio.dev
- 🐛 Issues: [GitHub Issues](https://github.com/yourdomain/lumio/issues)
- 📖 Documentation: [API Reference](https://pub.dev/documentation/lumio)

