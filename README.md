# Lumio

> **Inspired by Android Pluto** - Bringing the same powerful debugging capabilities to Flutter!

A simple and lightweight monitoring and logging SDK for Flutter applications. Lumio helps you monitor network calls, capture crashes, and log important events in your Flutter app.

## 🎯 What is Lumio?

Lumio is a Flutter plugin that provides:

- **Network Monitoring** - Automatically logs HTTP requests and responses
- **Crash Detection** - Captures and logs crashes and exceptions
- **ANR Monitoring** - Detects Application Not Responding events (Android)
- **Simple Logging** - Easy-to-use logging system with different levels

## 🚀 Quick Start

### 1. Add Dependency

Add Lumio to your `pubspec.yaml`:

```yaml
dependencies:
  lumio:
    path: ../lumio  # For local development
    # Or use git: https://github.com/amany2301/lumio.git
```

### 2. Initialize Lumio

In your `main.dart`:

```dart
import 'package:lumio/lumio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Lumio
  await Lumio.initialize(
    enableCrashMonitoring: true,
    enableAnrMonitoring: true,
  );
  
  runApp(MyApp());
}
```

### 3. Use Lumio HTTP Client

Replace your HTTP calls with Lumio's HTTP client for automatic logging:

```dart
import 'package:lumio/lumio.dart';

final httpClient = LumioHttpClient();

// GET request
final response = await httpClient.get('https://api.example.com/data');

// POST request
final response = await httpClient.post(
  'https://api.example.com/data',
  body: {'key': 'value'},
);
```

### 4. Manual Logging

```dart
// Log API responses
await Lumio.logApiResponse(url, statusCode, responseBody);

// Log network calls
await Lumio.logNetworkCall('GET', url, durationMs);

// Log crashes
await Lumio.logCrash(error, stackTrace);

// Log ANR events
await Lumio.logAnr('Application not responding');
```

## 📱 Features

### Network Monitoring
- Automatic logging of HTTP requests and responses
- Custom HTTP client with built-in logging
- Request/response timing and status codes

### Crash Detection
- Automatic crash capture and logging
- Manual crash logging support
- Stack trace preservation

### ANR Monitoring
- Android-specific Application Not Responding detection
- Automatic ANR event logging

### Simple Logging
- Easy-to-use logging utilities
- Different log levels (debug, info, warning, error)
- Console output with [Lumio] prefix

## 🔧 Configuration

### Initialize Options

```dart
await Lumio.initialize(
  enableCrashMonitoring: true,  // Enable crash detection
  enableAnrMonitoring: true,    // Enable ANR monitoring (Android only)
);
```

### HTTP Client Options

```dart
final httpClient = LumioHttpClient(
  timeout: Duration(seconds: 30),
  headers: {'Authorization': 'Bearer token'},
);
```

## 📊 Usage Examples

### Basic Network Monitoring

```dart
import 'package:lumio/lumio.dart';

class ApiService {
  final _httpClient = LumioHttpClient();
  
  Future<Map<String, dynamic>> fetchData() async {
    try {
      final response = await _httpClient.get('https://api.example.com/data');
      return response;
    } catch (e) {
      // Error will be automatically logged
      rethrow;
    }
  }
}
```

### Manual Crash Logging

```dart
try {
  // Your code here
} catch (e, stackTrace) {
  await Lumio.logCrash(e.toString(), stackTrace.toString());
  rethrow;
}
```

### Custom Logging

```dart
import 'package:lumio/lumio.dart';

// Log different types of events
await Lumio.logApiResponse('https://api.example.com/users', 200, '{"users": []}');
await Lumio.logNetworkCall('POST', 'https://api.example.com/users', 150);
```

## 🏗️ Project Structure

```
lib/
├── lumio.dart                    # Main Lumio class
├── lumio_platform_interface.dart # Platform interface
├── lumio_method_channel.dart     # Method channel implementation
└── src/
    ├── models/
    │   └── lumio_models.dart     # Data models
    ├── interceptors/
    │   └── lumio_http_interceptor.dart # HTTP client
    └── utils/
        └── lumio_logger.dart     # Logging utilities
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by [Android Pluto](https://github.com/androidPluto/pluto.git)
- Built with Flutter and Dart

