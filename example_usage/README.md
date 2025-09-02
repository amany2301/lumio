# Lumio Usage Example 🚀

This is a simple Flutter project that demonstrates how to integrate and use Lumio in your applications.

## 📦 Setup

### 1. Add Lumio to your project

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  lumio: ^0.0.1
```

### 2. Run pub get

```bash
flutter pub get
```

### 3. Initialize Lumio

In your `main.dart`:

```dart
import 'package:lumio/lumio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Lumio monitoring
  await Lumio.initialize(
    enableCrashMonitoring: true,
    enableAnrMonitoring: true,
    enableDebugOverlay: true,
  );
  
  runApp(MyApp());
}
```

## 🎯 Features Demonstrated

This example shows:

- ✅ **Network Monitoring**: Automatic HTTP request/response logging
- ✅ **Crash Detection**: Automatic and manual crash logging
- ✅ **Debug UI**: Floating debug overlay with monitoring screens
- ✅ **Manual Logging**: How to manually log events
- ✅ **Status Checking**: How to check Lumio's status

## 🚀 Running the Example

```bash
flutter run
```

## 📱 What You'll See

1. **Status Card**: Shows Lumio's initialization status
2. **Test Buttons**: Try different Lumio features
3. **Debug Overlay**: Access detailed monitoring screens
4. **Console Logs**: Check your IDE console for `[Lumio]` logs

## 🔍 Testing Features

### Network Monitoring
- Tap "Test GET Request" to make an HTTP GET call
- Tap "Test POST Request" to make an HTTP POST call
- All network calls are automatically logged

### Crash Monitoring
- Tap "Test Crash Logging" to manually log a crash
- Tap "Simulate Actual Crash" to trigger automatic crash detection
- Crashes are captured with stack traces

### Manual Logging
- Tap "Test Manual Logging" to manually log network events
- Useful for logging custom events or wrapping existing HTTP clients

## 📊 Viewing Results

### Console Logs
Check your IDE console for logs like:
```
flutter: [Lumio] 🌐 NETWORK CALL [2024-01-01T12:00:00.000Z]
flutter: [Lumio] GET https://jsonplaceholder.typicode.com/posts/1
flutter: [Lumio] Duration: 250ms
flutter: [Lumio] ============================================================
flutter: [Lumio] API RESPONSE [2024-01-01T12:00:00.000Z]
flutter: [Lumio] ============================================================
flutter: [Lumio] Method: GET
flutter: [Lumio] URL: https://jsonplaceholder.typicode.com/posts/1
flutter: [Lumio] Status: 200 (OK)
flutter: [Lumio] Duration: 250ms
flutter: [Lumio] Response Body:
flutter: [Lumio]   {
flutter: [Lumio]     "userId": 1,
flutter: [Lumio]     "id": 1,
flutter: [Lumio]     "title": "sunt aut facere repellat provident...",
flutter: [Lumio]     "body": "quia et suscipit suscipit recusandae..."
flutter: [Lumio]   }
```

### Debug Overlay
- Tap the bug icon in the app bar to toggle the debug overlay
- Access detailed monitoring screens for network, crashes, and logs

## 🔧 Key Code Patterns

### HTTP Client Usage
```dart
final LumioHttpClient _httpClient = LumioHttpClient();

// Automatic logging
await _httpClient.get('https://api.example.com/users');
await _httpClient.post('https://api.example.com/users', body: data);

// Don't forget to close
_httpClient.close();
```

### Manual Logging
```dart
// Log network calls
await Lumio.logNetworkCall('GET', 'https://api.example.com/users', 250);

// Log API responses
await Lumio.logApiResponse(
  'https://api.example.com/users',
  200,
  '{"users": []}',
);

// Log crashes
await Lumio.logCrash(
  'Exception message',
  'Stack trace...',
);
```

### Status Checking
```dart
print('Initialized: ${Lumio.isInitialized}');
print('Crash monitoring: ${Lumio.isCrashMonitoringEnabled}');
print('ANR monitoring: ${Lumio.isAnrMonitoringEnabled}');
print('Debug overlay: ${Lumio.isDebugOverlayEnabled}');
```

## 🎨 Customization

You can customize Lumio's behavior:

```dart
await Lumio.initialize(
  enableCrashMonitoring: true,  // Enable/disable crash detection
  enableAnrMonitoring: true,     // Enable/disable ANR detection (Android)
  enableDebugOverlay: true,     // Enable/disable debug UI
);
```

## 🚀 Next Steps

1. **Integrate into your app**: Follow the patterns shown in this example
2. **Customize logging**: Use manual logging for custom events
3. **Monitor in production**: Lumio logs to native platform logs
4. **Extend functionality**: Use the plugin architecture for custom features

## 📚 More Information

- **Full Documentation**: [USAGE_GUIDE.md](../USAGE_GUIDE.md)
- **GitHub Repository**: https://github.com/amany2301/lumio
- **Example App**: [example/](../example/)

---

**Lumio** - Making Flutter debugging easier! 🚀
