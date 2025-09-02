# Lumio 🚀 - Flutter Debugging Framework

**Lumio is an on-device debugging framework for Flutter applications**, which helps in the inspection of HTTP requests/responses, captures Crashes and ANRs, and manipulates application data on the go.

It comes with a UI to monitor and share the information, as well as APIs to access and use that information in your application.

> **Inspired by [Android Pluto](https://github.com/androidPluto/pluto.git)** - Bringing the same powerful debugging capabilities to Flutter!

## 🎯 What is Lumio?

Lumio is a comprehensive debugging framework that provides real-time monitoring, logging, and debugging capabilities for Flutter applications. Similar to Android Pluto, it offers:

- **Network Inspection**: Monitor HTTP requests/responses with detailed analysis
- **Crash Detection**: Capture and analyze crashes with stack traces
- **ANR Monitoring**: Detect Application Not Responding events (Android)
- **Data Manipulation**: Inspect and modify app data on-the-go
- **Plugin Architecture**: Extensible plugin system for custom debugging tools
- **Debug UI**: Rich interface for monitoring and sharing debug information

## ✨ Features

### 🔌 Plugin System
- **Modular Architecture**: Add only the plugins you need
- **Custom Plugins**: Create your own debugging plugins
- **Plugin Groups**: Organize plugins into logical groups
- **Hot Reload Support**: Plugins work seamlessly with Flutter hot reload

### 🌐 Network Plugin
- **HTTP Request/Response Inspection**: View all network traffic
- **cURL Generation**: Copy requests as cURL commands
- **Performance Metrics**: Request duration, size, and timing
- **Header Analysis**: Inspect request and response headers
- **Body Inspection**: View formatted JSON/XML responses

### 🐛 Crash Plugin
- **Flutter Exception Capture**: Automatic crash detection
- **Native Crash Handling**: iOS/Android native crash capture
- **Stack Trace Analysis**: Detailed error analysis
- **Crash Reports**: Exportable crash reports
- **ANR Detection**: Application Not Responding monitoring (Android)

### 📝 Logger Plugin
- **Multi-level Logging**: Verbose, Debug, Info, Warning, Error, Fatal
- **Real-time Log Streaming**: Live log monitoring
- **Log Filtering**: Filter by level, tag, or content
- **Log Export**: Export logs for analysis
- **Session Tracking**: Track logs per user session

### 💾 Data Plugins
- **Shared Preferences Inspector**: View and modify SharedPreferences
- **Database Inspector**: Inspect SQLite databases
- **File System Browser**: Browse app's file system
- **Memory Profiler**: Monitor memory usage

### 🎨 Debug UI
- **Floating Debug Button**: Quick access to debug tools
- **Notification Integration**: System notifications for debug access
- **Dark/Light Theme**: Adaptive UI themes
- **Responsive Design**: Works on all screen sizes
- **Export Features**: Share debug data via email, files, etc.

## 🚀 Installation

### Add Dependencies

Add Lumio to your `pubspec.yaml`:

```yaml
dependencies:
  lumio: ^0.0.1

dev_dependencies:
  # For development builds
  lumio: ^0.0.1
```

### Initialize Lumio

Initialize Lumio in your app's main function:

```dart
import 'package:flutter/material.dart';
import 'package:lumio/lumio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Lumio with plugins
  await Lumio.initialize(
    enableCrashMonitoring: true,
    enableAnrMonitoring: true,
    plugins: [
      NetworkPlugin(),
      CrashPlugin(),
      LoggerPlugin(),
      SharedPreferencesPlugin(),
    ],
  );
  
  runApp(MyApp());
}
```

## 🔌 Plugin Integration

### Core Plugin Bundle

For quick setup, use the core plugin bundle:

```dart
await Lumio.initialize(
  plugins: [
    CorePluginBundle(), // Includes Network, Crash, and Logger plugins
  ],
);
```

### Individual Plugins

Add specific plugins based on your needs:

```dart
await Lumio.initialize(
  plugins: [
    NetworkPlugin(),
    CrashPlugin(),
    LoggerPlugin(),
    SharedPreferencesPlugin(),
    DatabasePlugin(),
    FileSystemPlugin(),
  ],
);
```

### Plugin Groups

Organize plugins into groups for better categorization:

```dart
class DataSourcePluginGroup extends PluginGroup {
  @override
  String get name => 'DataSource Group';
  
  @override
  List<Plugin> get plugins => [
    SharedPreferencesPlugin(),
    DatabasePlugin(),
    FileSystemPlugin(),
  ];
}

await Lumio.initialize(
  pluginGroups: [
    DataSourcePluginGroup(),
  ],
);
```

## 📱 Usage Examples

### Network Monitoring

```dart
// Automatic monitoring with LumioHttpClient
final client = LumioHttpClient();

// All requests are automatically logged
final response = await client.get('https://api.example.com/users');
final postResponse = await client.post(
  'https://api.example.com/users',
  body: {'name': 'John', 'email': 'john@example.com'},
);

client.close();
```

### Manual Logging

```dart
// Log network calls
await Lumio.logNetworkCall('GET', 'https://api.example.com/users', 250);

// Log API responses
await Lumio.logApiResponse(
  'https://api.example.com/users',
  200,
  '{"users": [{"id": 1, "name": "John"}]}',
);

// Log crashes
await Lumio.logCrash(
  'Exception: Null check operator used on a null value',
  'Stack trace here...',
);

// Log ANRs (Android only)
await Lumio.logAnr('Main thread blocked for 5000ms');
```

### Debug UI Access

```dart
// Show debug overlay
Lumio.showDebugOverlay();

// Hide debug overlay
Lumio.hideDebugOverlay();

// Toggle debug overlay
Lumio.toggleDebugOverlay();
```

## 🎨 Debug UI Features

### Floating Debug Button
- **Always Accessible**: Floating button for quick debug access
- **Customizable Position**: Drag to reposition
- **Minimal Intrusion**: Small, unobtrusive design

### Debug Screens
- **Network Monitor**: View all HTTP traffic
- **Crash Monitor**: Analyze crashes and exceptions
- **Logger Monitor**: Browse and filter logs
- **Data Inspector**: Inspect app data

### Export Features
- **Share Debug Data**: Export via email, files, or clipboard
- **Screenshot Capture**: Capture debug screens
- **Data Export**: Export logs, crashes, and network data

## 🔧 Configuration

### Basic Configuration

```dart
await Lumio.initialize(
  enableCrashMonitoring: true,
  enableAnrMonitoring: true,
  enableDebugOverlay: true,
  maxStoredLogs: 10000,
  plugins: [
    NetworkPlugin(),
    CrashPlugin(),
    LoggerPlugin(),
  ],
);
```

### Plugin-Specific Configuration

```dart
await Lumio.initialize(
  plugins: [
    NetworkPlugin(
      enableCurlGeneration: true,
      maxStoredRequests: 1000,
      enableBodyInspection: true,
    ),
    CrashPlugin(
      enableNativeCrashCapture: true,
      enableANRDetection: true,
      maxStoredCrashes: 100,
    ),
    LoggerPlugin(
      minLogLevel: LogLevel.debug,
      enableRealTimeStreaming: true,
      maxStoredLogs: 5000,
    ),
  ],
);
```

## 🧪 Testing

### Run Tests

```bash
flutter test
```

### Example App

```bash
cd example
flutter run
```

The example app demonstrates:
- All plugin features
- Debug UI usage
- Network monitoring
- Crash simulation
- Log management

## 🔌 Creating Custom Plugins

Lumio supports custom plugins. Here's how to create one:

```dart
class CustomPlugin extends Plugin {
  @override
  String get name => 'Custom Plugin';
  
  @override
  String get description => 'A custom debugging plugin';
  
  @override
  Widget buildDebugScreen() {
    return CustomDebugScreen();
  }
  
  @override
  void initialize() {
    // Plugin initialization logic
  }
  
  @override
  void dispose() {
    // Cleanup logic
  }
}
```

## 📊 Comparison with Android Pluto

| Feature | Android Pluto | Lumio (Flutter) |
|---------|--------------|-----------------|
| Network Inspection | ✅ | ✅ |
| Crash Detection | ✅ | ✅ |
| ANR Monitoring | ✅ | ✅ (Android) |
| Plugin Architecture | ✅ | ✅ |
| Debug UI | ✅ | ✅ |
| Cross-Platform | ❌ (Android only) | ✅ (iOS + Android) |
| Hot Reload Support | ❌ | ✅ |
| Custom Plugins | ✅ | ✅ |
| Data Inspection | ✅ | ✅ |

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md).

### Development Setup

1. Fork the repository
2. Clone your fork
3. Create a feature branch
4. Make your changes
5. Add tests
6. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by [Android Pluto](https://github.com/androidPluto/pluto.git)
- Built for the Flutter community
- Thanks to all contributors and users

## 📞 Support

- **Documentation**: [GitHub Wiki](https://github.com/amany2301/lumio/wiki)
- **Issues**: [GitHub Issues](https://github.com/amany2301/lumio/issues)
- **Discussions**: [GitHub Discussions](https://github.com/amany2301/lumio/discussions)

---

**Lumio** - The Flutter equivalent of Android Pluto! 🚀

*Bringing powerful debugging capabilities to Flutter applications*

