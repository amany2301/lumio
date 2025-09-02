# Lumio Usage Guide 🚀

This guide shows you how to integrate and use Lumio in your Flutter projects for comprehensive debugging and monitoring.

## 📦 Installation

### 1. Add Lumio to your `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  lumio: ^0.0.1  # Add this line
```

### 2. Run pub get

```bash
flutter pub get
```

## 🚀 Quick Start

### 1. Initialize Lumio in your main.dart

```dart
import 'package:flutter/material.dart';
import 'package:lumio/lumio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Lumio monitoring
  await Lumio.initialize(
    enableCrashMonitoring: true,
    enableAnrMonitoring: true, // Android only
    enableDebugOverlay: true,
  );
  
  runApp(MyApp());
}
```

### 2. Wrap your app with LumioApp (Optional)

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LumioApp(
      enableDebugOverlay: true,
      child: MaterialApp(
        title: 'My App',
        home: MyHomePage(),
      ),
    );
  }
}
```

## 🔍 Basic Usage

### Network Monitoring

#### Automatic HTTP Logging with LumioHttpClient

```dart
import 'package:lumio/lumio.dart';

class ApiService {
  final LumioHttpClient _httpClient = LumioHttpClient();
  
  Future<void> fetchUsers() async {
    try {
      // This automatically logs both the network call and API response
      final response = await _httpClient.get('https://api.example.com/users');
      
      // Process response...
    } catch (e) {
      print('Error: $e');
    }
  }
  
  Future<void> createUser(Map<String, dynamic> userData) async {
    try {
      // POST request with automatic logging
      final response = await _httpClient.post(
        'https://api.example.com/users',
        body: userData,
      );
      
      // Process response...
    } catch (e) {
      print('Error: $e');
    }
  }
  
  void dispose() {
    _httpClient.close(); // Don't forget to close the client
  }
}
```

#### Manual Network Logging

```dart
import 'package:lumio/lumio.dart';

// Log network calls manually
await Lumio.logNetworkCall('GET', 'https://api.example.com/users', 250);

// Log API responses manually
await Lumio.logApiResponse(
  'https://api.example.com/users',
  200,
  '{"users": [{"id": 1, "name": "John"}]}',
);
```

### Crash Monitoring

#### Automatic Crash Detection

Lumio automatically captures Flutter and native crashes when initialized:

```dart
// Crashes are automatically logged when they occur
// No additional code needed!
```

#### Manual Crash Logging

```dart
import 'package:lumio/lumio.dart';

try {
  // Your code that might crash
  throw Exception('Something went wrong');
} catch (e, stackTrace) {
  // Manually log the crash
  await Lumio.logCrash(
    e.toString(),
    stackTrace.toString(),
  );
}
```

### ANR Monitoring (Android Only)

```dart
import 'package:lumio/lumio.dart';

// ANR events are automatically detected on Android
// You can also manually log ANR events
await Lumio.logAnr('Main thread blocked for 5000ms');
```

## 🎨 Debug UI Features

### Access Debug Overlay

```dart
import 'package:lumio/lumio.dart';

// Show debug overlay
Lumio.showDebugOverlay();

// Hide debug overlay
Lumio.hideDebugOverlay();

// Toggle debug overlay
Lumio.toggleDebugOverlay();
```

### Debug Screens

The debug overlay provides access to:

- **Network Monitor**: View all HTTP requests and responses
- **Crash Monitor**: Analyze crashes and exceptions
- **Logger Monitor**: Browse and filter logs
- **Log Viewer**: Detailed log inspection

## 📝 Advanced Logging

### Using LumioLogger

```dart
import 'package:lumio/src/utils/lumio_logger.dart';

// Simple logging
LumioLogger.log('This is a log message');
LumioLogger.info('This is an info message');
LumioLogger.warning('This is a warning message');
LumioLogger.error('This is an error message');
LumioLogger.success('This is a success message');

// Enhanced API response logging
LumioLogger.logApiResponse(
  url: 'https://api.example.com/users',
  statusCode: 200,
  method: 'GET',
  responseBody: '{"users": []}',
  headers: {'content-type': 'application/json'},
  requestBody: null,
  durationMs: 250,
);
```

### HTTP Interceptor

```dart
import 'package:lumio/lumio.dart';

// Wrap your HTTP calls for automatic logging
final result = await LumioHttpInterceptor.wrapResponse(
  () => http.get(Uri.parse('https://api.example.com/users')),
  'GET',
  'https://api.example.com/users',
);

// Log responses manually
LumioHttpInterceptor.logResponse(url, statusCode, responseBody);

// Log errors manually
LumioHttpInterceptor.logError(url, errorMessage);
```

## 🔧 Configuration Options

### Basic Configuration

```dart
await Lumio.initialize(
  enableCrashMonitoring: true,  // Enable crash detection
  enableAnrMonitoring: true,     // Enable ANR detection (Android only)
  enableDebugOverlay: true,     // Enable debug UI
);
```

### Check Status

```dart
// Check if Lumio is initialized
print('Initialized: ${Lumio.isInitialized}');

// Check if crash monitoring is enabled
print('Crash monitoring: ${Lumio.isCrashMonitoringEnabled}');

// Check if ANR monitoring is enabled
print('ANR monitoring: ${Lumio.isAnrMonitoringEnabled}');

// Check if debug overlay is enabled
print('Debug overlay: ${Lumio.isDebugOverlayEnabled}');
```

## 📱 Platform Support

| Feature | Android | iOS |
|---------|---------|-----|
| Network Monitoring | ✅ | ✅ |
| Crash Detection | ✅ | ✅ |
| ANR Detection | ✅ | ❌ |
| Debug UI | ✅ | ✅ |
| HTTP Client | ✅ | ✅ |

## 🏗️ Complete Example

Here's a complete example of how to use Lumio in a Flutter app:

```dart
import 'package:flutter/material.dart';
import 'package:lumio/lumio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Lumio
  await Lumio.initialize(
    enableCrashMonitoring: true,
    enableAnrMonitoring: true,
    enableDebugOverlay: true,
  );
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LumioApp(
      enableDebugOverlay: true,
      child: MaterialApp(
        title: 'Lumio Example',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final LumioHttpClient _httpClient = LumioHttpClient();
  
  @override
  void dispose() {
    _httpClient.close();
    super.dispose();
  }
  
  Future<void> _testNetworkCall() async {
    try {
      // This will be automatically logged
      await _httpClient.get('https://jsonplaceholder.typicode.com/posts/1');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network call completed!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  
  Future<void> _testCrashLogging() async {
    try {
      // Manually log a crash
      await Lumio.logCrash(
        'Test Exception: Something went wrong',
        'Stack trace here...',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Crash logged!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lumio Example'),
        actions: [
          IconButton(
            icon: Icon(Icons.bug_report),
            onPressed: () => Lumio.toggleDebugOverlay(),
            tooltip: 'Toggle Debug Overlay',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _testNetworkCall,
              child: Text('Test Network Call'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _testCrashLogging,
              child: Text('Test Crash Logging'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 🔍 Viewing Debug Information

### In Development

1. **Debug Overlay**: Tap the floating debug button or use `Lumio.toggleDebugOverlay()`
2. **Console Logs**: Check your IDE's console for `[Lumio]` prefixed logs
3. **Network Monitor**: View HTTP requests and responses in real-time
4. **Crash Monitor**: Analyze crashes with stack traces

### In Production

Lumio automatically logs to the platform's native logging system:
- **Android**: Uses `Log.d()`, `Log.e()`, etc.
- **iOS**: Uses `print()` statements

## 🚀 Best Practices

1. **Initialize Early**: Call `Lumio.initialize()` in your `main()` function
2. **Close HTTP Client**: Always call `_httpClient.close()` in dispose
3. **Use Debug Overlay**: Enable it during development for easy access
4. **Monitor Logs**: Check console output for `[Lumio]` prefixed messages
5. **Handle Errors**: Wrap network calls in try-catch blocks

## 🆘 Troubleshooting

### Common Issues

1. **"Target file not found"**: Make sure you're in the correct directory
2. **Import errors**: Run `flutter pub get` after adding Lumio
3. **Debug overlay not showing**: Check if `enableDebugOverlay: true` is set
4. **Network calls not logged**: Use `LumioHttpClient` or manual logging

### Getting Help

- Check the [example app](example/) for complete usage patterns
- Review the [API documentation](lib/)
- Open an issue on [GitHub](https://github.com/amany2301/lumio/issues)

---

**Lumio** - Making Flutter debugging easier! 🚀
