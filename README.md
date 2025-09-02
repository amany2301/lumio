# Lumio

**On-device debugging framework for Flutter applications**

Lumio helps in the inspection of HTTP requests/responses, captures Crashes and ANRs, and provides APIs to access debugging information. It comes with a UI to monitor and share the information, as well as APIs to access and use that information in your application.

## Features

### 🔍 HTTP Request/Response Inspection
- **Automatic HTTP logging** with detailed request and response information
- **cURL command generation** for easy API testing
- **Request/response headers** and body inspection
- **Performance metrics** including request duration
- **Error tracking** with detailed stack traces

### 🐛 Crash and ANR Capture
- **Automatic crash detection** for Flutter and native errors
- **ANR (Application Not Responding) monitoring** for Android
- **Detailed stack traces** for debugging
- **Error categorization** and filtering

### 📱 On-Device UI
- **Floating debug overlay** with real-time metrics
- **Expandable debug panel** showing HTTP, crash, and ANR counts
- **Quick actions** for clearing logs and sharing data
- **Non-intrusive** design that doesn't interfere with your app

### 🔧 APIs for Data Access
- **HTTP client wrapper** with automatic logging
- **Manual logging APIs** for custom debugging
- **Programmatic access** to debugging information
- **Configurable logging levels** and options

## Installation

Add Lumio to your `pubspec.yaml`:

```yaml
dependencies:
  lumio: ^0.0.1
```

## Quick Start

### 1. Initialize Lumio

```dart
import 'package:lumio/lumio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Lumio debugging framework
  await Lumio.initialize(
    enableCrashMonitoring: true,
    enableAnrMonitoring: true,
  );
  
  runApp(const MyApp());
}
```

### 2. Wrap Your App with Debug Overlay

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

### 3. Use HTTP Client for Automatic Logging

```dart
import 'package:lumio/lumio.dart';

class MyService {
  final LumioHttpClient _httpClient = LumioHttpClient();
  
  Future<void> fetchData() async {
    try {
      // This automatically logs HTTP request and response
      final response = await _httpClient.get('https://api.example.com/data');
      // Process response...
    } catch (e) {
      // Errors are automatically logged
    }
  }
  
  void dispose() {
    _httpClient.close();
  }
}
```

### 4. Manual Logging

```dart
// Log HTTP request
await Lumio.logHttpRequest(
  method: 'POST',
  url: 'https://api.example.com/users',
  headers: {'Content-Type': 'application/json'},
  body: '{"name": "John Doe"}',
);

// Log HTTP response
await Lumio.logHttpResponse(
  url: 'https://api.example.com/users',
  statusCode: 201,
  body: '{"id": 123, "name": "John Doe"}',
  headers: {'Content-Type': 'application/json'},
  durationMs: 250,
);

// Log crash
await Lumio.logCrash(
  'Division by zero error',
  StackTrace.current.toString(),
);

// Log ANR (Android only)
await Lumio.logAnr('Main thread blocked for 5000ms');
```

## Debug UI

Lumio provides a floating debug overlay that shows:

- **HTTP request count** (green)
- **Crash count** (red)  
- **ANR count** (orange)

Tap the floating button to expand the panel and access:
- Detailed metrics
- Clear logs button
- Share logs button

## Viewing Logs

### iOS (Recommended)
1. Open Xcode
2. Go to Window → Devices and Simulators
3. Select your device/simulator
4. Click "Open Console"
5. Filter by "[Lumio]" to see only your logs

### Terminal/VS Code
1. Run: `flutter logs`
2. Look for `[Lumio]` entries
3. Copy cURL commands to test in terminal

## Configuration

### Logger Settings

```dart
// Disable detailed logging
LumioLogger.setDetailedLogging(false);

// Disable cURL generation
LumioLogger.setCurlGeneration(false);
```

### Debug Overlay Settings

```dart
LumioApp(
  enableDebugOverlay: false, // Disable debug overlay
  child: MyApp(),
)
```

## Example

See the `example/` directory for a complete working example that demonstrates:

- HTTP request/response logging
- Crash simulation and capture
- ANR monitoring
- Debug overlay usage
- Manual logging APIs

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- 📧 Email: [your-email@example.com]
- 🐛 Issues: [GitHub Issues](https://github.com/amany2301/lumio/issues)
- 📖 Documentation: [GitHub Wiki](https://github.com/amany2301/lumio/wiki)

