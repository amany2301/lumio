# 🚀 Lumio Installation - Super Easy!

Choose your preferred installation method:

## 🎯 Method 1: One-Liner Installation (Recommended)

### For New Projects
```bash
curl -sSL https://raw.githubusercontent.com/amany2301/lumio/main/scripts/install_lumio.sh | bash
```

### For Existing Projects
```bash
curl -sSL https://raw.githubusercontent.com/amany2301/lumio/main/scripts/install_lumio.sh | bash -s add
```

## 🛠️ Method 2: Manual Installation

### Step 1: Add to pubspec.yaml
```yaml
dependencies:
  lumio: ^0.0.1
```

### Step 2: Initialize in main.dart
```dart
import 'package:lumio/lumio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Lumio.initialize(
    enableCrashMonitoring: true,
    enableAnrMonitoring: true,
    enableDebugOverlay: true,
  );
  
  runApp(MyApp());
}
```

### Step 3: Run
```bash
flutter pub get
flutter run
```

## 🎨 Method 3: Use Project Template

### Clone the template
```bash
git clone https://github.com/amany2301/lumio.git
cd lumio/templates/flutter_project_template
flutter create my_app
cd my_app
flutter pub get
flutter run
```

## 🧪 Method 4: Test Integration

After installation, test that everything works:

```bash
# Test the integration
curl -sSL https://raw.githubusercontent.com/amany2301/lumio/main/scripts/install_lumio.sh | bash -s test
```

## 📱 What You Get

✅ **Automatic Features**
- Network monitoring (HTTP requests/responses)
- Crash detection (Flutter & native)
- ANR monitoring (Android)
- Debug overlay UI

✅ **Manual Features**
- Manual logging
- Status checking
- Data export

## 🚀 Quick Start

1. **Install**: Choose any method above
2. **Run**: `flutter run`
3. **Test**: Tap the bug icon in the app bar
4. **Monitor**: Check console for `[Lumio]` logs

## 📊 View Results

- **Console**: Check IDE console for `[Lumio]` logs
- **Debug Overlay**: Tap bug icon for detailed monitoring
- **Network Monitor**: View HTTP requests/responses
- **Crash Monitor**: Analyze crashes with stack traces

## 🔧 Configuration

Customize Lumio behavior:

```dart
await Lumio.initialize(
  enableCrashMonitoring: true,  // Enable/disable crash detection
  enableAnrMonitoring: true,     // Enable/disable ANR detection (Android)
  enableDebugOverlay: true,     // Enable/disable debug UI
);
```

## 🆘 Troubleshooting

### Common Issues

1. **"Not in Flutter project"**: Run from your Flutter project root
2. **Import errors**: Run `flutter pub get` after adding dependency
3. **Debug overlay not showing**: Check if `enableDebugOverlay: true` is set
4. **Network calls not logged**: Use `LumioHttpClient` or manual logging

### Getting Help

- 📚 **Documentation**: [USAGE_GUIDE.md](USAGE_GUIDE.md)
- 🐛 **Issues**: [GitHub Issues](https://github.com/amany2301/lumio/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/amany2301/lumio/discussions)

---

**Lumio** - Making Flutter debugging easier! 🚀
