# Lumio 🚀

A comprehensive monitoring and logging SDK for Flutter applications. Lumio provides real-time logging for API responses, network calls, crashes, and ANRs (Application Not Responding events) on both Android and iOS platforms.

## Features ✨

- **API Response Logging**: Automatically log HTTP responses with URL, status code, and response body
- **Network Call Logging**: Track network requests with method, URL, and duration
- **Crash Monitoring**: Capture and log both Flutter and native crashes with stack traces
- **ANR Detection**: Monitor and log Application Not Responding events (Android only)
- **Cross-Platform**: Full support for both Android and iOS
- **Easy Integration**: Simple setup with minimal configuration
- **HTTP Client Wrapper**: Built-in HTTP client with automatic logging

## Installation 🚀

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  lumio: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## Quick Start 🏃‍♂️

### 1. Initialize Lumio

Initialize Lumio in your app's main function:

```dart
import 'package:flutter/material.dart';
import 'package:lumio/lumio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Lumio monitoring
  await Lumio.initialize(
    enableCrashMonitoring: true,
    enableAnrMonitoring: true, // Android only
  );
  
  runApp(MyApp());
}
```

### 2. Manual Logging

Use Lumio static methods to manually log events:

```dart
// Log API responses
await Lumio.logApiResponse(
  'https://api.example.com/users',
  200,
  '{"users": [{"id": 1, "name": "John"}]}',
);

// Log network calls
await Lumio.logNetworkCall('GET', 'https://api.example.com/users', 250);

// Log crashes
await Lumio.logCrash(
  'Exception: Null check operator used on a null value',
  'Stack trace here...',
);

// Log ANRs (Android only)
await Lumio.logAnr('Main thread blocked for 5000ms');
```

### 3. Automatic HTTP Logging

Use the built-in HTTP client for automatic logging:

```dart
import 'package:lumio/lumio.dart';

final httpClient = LumioHttpClient();

// This automatically logs both the network call and API response
final response = await httpClient.get('https://api.example.com/users');

// Don't forget to close the client when done
httpClient.close();
```

## Advanced Usage 🔧

### HTTP Interceptor

For manual HTTP request wrapping:

```dart
import 'package:lumio/lumio.dart';

// Wrap your HTTP calls
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

### Configuration Options

```dart
await Lumio.initialize(
  enableCrashMonitoring: true,  // Enable crash detection
  enableAnrMonitoring: true,    // Enable ANR detection (Android only)
);

// Check initialization status
print('Initialized: ${Lumio.isInitialized}');
print('Crash monitoring: ${Lumio.isCrashMonitoringEnabled}');
print('ANR monitoring: ${Lumio.isAnrMonitoringEnabled}');
```

## Platform Support 📱

| Feature | Android | iOS |
|---------|---------|-----|
| API Response Logging | ✅ | ✅ |
| Network Call Logging | ✅ | ✅ |
| Crash Monitoring | ✅ | ✅ |
| ANR Detection | ✅ | ❌ |

## Data Models 📊

Lumio includes built-in data models for structured logging:

```dart
// Network call log
final networkLog = NetworkCallLog(
  method: 'GET',
  url: 'https://api.example.com',
  durationMs: 250,
  timestamp: DateTime.now(),
);

// API response log
final apiLog = ApiResponseLog(
  url: 'https://api.example.com',
  statusCode: 200,
  body: 'response body',
  timestamp: DateTime.now(),
);

// Crash log
final crashLog = CrashLog(
  error: 'Exception message',
  stackTrace: 'Stack trace...',
  timestamp: DateTime.now(),
);

// ANR log
final anrLog = AnrLog(
  message: 'Main thread blocked',
  timestamp: DateTime.now(),
);
```

## Implementation Details 🔍

### Android Implementation

- **Logging**: Uses Android's `Log` class with appropriate log levels
- **Crash Handling**: Implements `Thread.UncaughtExceptionHandler`
- **ANR Detection**: Custom ANR watchdog monitors main thread responsiveness
- **Method Channel**: Communicates with Flutter via `MethodChannel`

### iOS Implementation

- **Logging**: Uses `print()` statements for console output
- **Crash Handling**: Uses `NSSetUncaughtExceptionHandler` and signal handlers
- **ANR Detection**: Not applicable (iOS handles this differently)
- **Method Channel**: Communicates with Flutter via `FlutterMethodChannel`

## Example App 📱

The example app demonstrates all Lumio features:

```bash
cd example
flutter run
```

Features demonstrated:
- Manual API response logging
- Manual network call logging
- Manual crash logging
- Manual ANR logging
- Automatic HTTP client logging
- Crash simulation

## Testing 🧪

Run the tests:

```bash
flutter test
```

The test suite includes:
- Platform interface tests
- Method channel tests
- Mock implementations
- Integration tests

## Contributing 🤝

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License 📄

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Changelog 📝

See [CHANGELOG.md](CHANGELOG.md) for a detailed history of changes.

## Support 💬

If you encounter any issues or have questions:

1. Check the [example app](example/) for usage patterns
2. Review the [API documentation](lib/)
3. Open an issue on GitHub

---

**Lumio** - Comprehensive monitoring made simple for Flutter apps! 🚀

