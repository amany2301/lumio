#!/bin/bash

# Lumio Installation Script
# Makes Flutter debugging super easy!

set -e

echo "🚀 Lumio - Flutter Debugging Made Easy!"
echo "======================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}📦 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if we're in a Flutter project
check_flutter_project() {
    if [ ! -f "pubspec.yaml" ]; then
        print_error "Not in a Flutter project directory"
        echo "Please run this script from your Flutter project root"
        exit 1
    fi
    
    if ! grep -q "flutter:" pubspec.yaml; then
        print_error "This doesn't appear to be a Flutter project"
        exit 1
    fi
}

# Add Lumio dependency
add_dependency() {
    print_status "Adding Lumio dependency to pubspec.yaml..."
    
    if grep -q "lumio:" pubspec.yaml; then
        print_warning "Lumio dependency already exists"
        return
    fi
    
    # Find the dependencies section and add lumio
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' '/dependencies:/a\
  lumio: ^0.0.1' pubspec.yaml
    else
        # Linux
        sed -i '/dependencies:/a\  lumio: ^0.0.1' pubspec.yaml
    fi
    
    print_success "Added lumio: ^0.0.1 to dependencies"
}

# Create main.dart with Lumio
create_main_dart() {
    print_status "Creating main.dart with Lumio integration..."
    
    if [ -f "lib/main.dart" ]; then
        print_warning "lib/main.dart already exists, creating backup..."
        cp lib/main.dart lib/main.dart.backup
    fi
    
    mkdir -p lib
    
    cat > lib/main.dart << 'EOF'
import 'package:flutter/material.dart';
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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LumioApp(
      enableDebugOverlay: true,
      child: MaterialApp(
        title: 'Lumio Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
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
      await _httpClient.get('https://jsonplaceholder.typicode.com/posts/1');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Network call logged!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lumio Demo'),
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
            Text(
              'Lumio is running!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _testNetworkCall,
              child: Text('Test Network Call'),
            ),
            SizedBox(height: 10),
            Text(
              'Check console for [Lumio] logs',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
EOF

    print_success "Created lib/main.dart with Lumio integration"
}

# Update existing main.dart
update_main_dart() {
    print_status "Updating existing main.dart with Lumio..."
    
    if [ ! -f "lib/main.dart" ]; then
        print_error "lib/main.dart not found"
        return
    fi
    
    # Check if Lumio is already initialized
    if grep -q "Lumio.initialize" lib/main.dart; then
        print_warning "Lumio already initialized in main.dart"
        return
    fi
    
    # Create backup
    cp lib/main.dart lib/main.dart.backup
    
    # Add import
    if ! grep -q "import 'package:lumio/lumio.dart';" lib/main.dart; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' '1i\
import '\''package:lumio/lumio.dart'\'';' lib/main.dart
        else
            sed -i '1i\import '\''package:lumio/lumio.dart'\'';' lib/main.dart
        fi
    fi
    
    # Add initialization
    if grep -q "void main()" lib/main.dart; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' 's/void main() {/void main() async {\n  WidgetsFlutterBinding.ensureInitialized();\n  \n  \/\/ Initialize Lumio monitoring\n  await Lumio.initialize(\n    enableCrashMonitoring: true,\n    enableAnrMonitoring: true,\n    enableDebugOverlay: true,\n  );\n  \n  /' lib/main.dart
        else
            sed -i 's/void main() {/void main() async {\n  WidgetsFlutterBinding.ensureInitialized();\n  \n  \/\/ Initialize Lumio monitoring\n  await Lumio.initialize(\n    enableCrashMonitoring: true,\n    enableAnrMonitoring: true,\n    enableDebugOverlay: true,\n  );\n  \n  /' lib/main.dart
        fi
    fi
    
    print_success "Updated main.dart with Lumio initialization"
}

# Create example screen
create_example_screen() {
    print_status "Creating example screen..."
    
    mkdir -p lib/screens
    
    if [ -f "lib/screens/lumio_example_screen.dart" ]; then
        print_warning "Example screen already exists"
        return
    fi
    
    cat > lib/screens/lumio_example_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:lumio/lumio.dart';

class LumioExampleScreen extends StatefulWidget {
  @override
  _LumioExampleScreenState createState() => _LumioExampleScreenState();
}

class _LumioExampleScreenState extends State<LumioExampleScreen> {
  final LumioHttpClient _httpClient = LumioHttpClient();
  String _statusMessage = 'Ready to test Lumio features';
  
  @override
  void dispose() {
    _httpClient.close();
    super.dispose();
  }
  
  Future<void> _testNetworkCall() async {
    setState(() {
      _statusMessage = 'Making network call...';
    });
    
    try {
      await _httpClient.get('https://jsonplaceholder.typicode.com/posts/1');
      setState(() {
        _statusMessage = 'Network call completed! Check console for logs.';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Network call failed: $e';
      });
    }
  }
  
  Future<void> _testCrashLogging() async {
    try {
      await Lumio.logCrash(
        'Test Exception: This is a simulated crash',
        'Stack trace here...',
      );
      setState(() {
        _statusMessage = 'Crash logged successfully!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Crash logging failed: $e';
      });
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
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(_statusMessage),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _testNetworkCall,
              child: Text('Test Network Call'),
            ),
            SizedBox(height: 10),
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
EOF

    print_success "Created example screen at lib/screens/lumio_example_screen.dart"
}

# Update README
update_readme() {
    print_status "Updating README..."
    
    if [ ! -f "README.md" ]; then
        print_warning "README.md not found, creating new one..."
        create_readme
        return
    fi
    
    if grep -q "Lumio" README.md; then
        print_warning "README already mentions Lumio"
        return
    fi
    
    # Add Lumio section to existing README
    cat >> README.md << 'EOF'

## 🚀 Lumio Integration

This project uses [Lumio](https://github.com/amany2301/lumio) for debugging and monitoring.

### Features
- ✅ Network monitoring
- ✅ Crash detection  
- ✅ Debug overlay
- ✅ ANR monitoring (Android)

### Usage
- Check console for `[Lumio]` logs
- Tap the bug icon to access debug overlay
- All HTTP calls are automatically logged

For more information, see the [Lumio documentation](https://github.com/amany2301/lumio).
EOF

    print_success "Updated README with Lumio information"
}

# Create README
create_readme() {
    cat > README.md << 'EOF'
# My Flutter App

A Flutter application with Lumio integration for debugging and monitoring.

## 🚀 Getting Started

1. Run `flutter pub get`
2. Run `flutter run`
3. Check console for `[Lumio]` logs
4. Tap the bug icon to access debug overlay

## 🛠️ Lumio Integration

This project uses [Lumio](https://github.com/amany2301/lumio) for comprehensive debugging:

### Features
- ✅ Network monitoring
- ✅ Crash detection  
- ✅ Debug overlay
- ✅ ANR monitoring (Android)

### Usage
- All HTTP calls are automatically logged
- Crashes are automatically captured
- Use debug overlay for detailed monitoring

For more information, see the [Lumio documentation](https://github.com/amany2301/lumio).
EOF

    print_success "Created README.md with Lumio information"
}

# Run flutter pub get
run_pub_get() {
    print_status "Running flutter pub get..."
    
    if command -v flutter >/dev/null 2>&1; then
        flutter pub get
        print_success "Dependencies installed"
    else
        print_error "Flutter not found in PATH"
        echo "Please install Flutter and run: flutter pub get"
    fi
}

# Main installation function
install_lumio() {
    echo "🎯 Installing Lumio..."
    echo ""
    
    check_flutter_project
    add_dependency
    create_main_dart
    create_example_screen
    update_readme
    run_pub_get
    
    echo ""
    print_success "Lumio installation completed!"
    echo ""
    echo "🚀 Next steps:"
    echo "1. Run: flutter run"
    echo "2. Check console for [Lumio] logs"
    echo "3. Tap the bug icon to access debug overlay"
    echo "4. Test network calls and crash logging"
    echo ""
    echo "📚 Documentation: https://github.com/amany2301/lumio"
}

# Add to existing project
add_to_existing() {
    echo "➕ Adding Lumio to existing project..."
    echo ""
    
    check_flutter_project
    add_dependency
    update_main_dart
    run_pub_get
    
    echo ""
    print_success "Lumio added to existing project!"
    echo ""
    echo "🚀 Next steps:"
    echo "1. Restart your app"
    echo "2. Check console for [Lumio] logs"
    echo "3. Use LumioHttpClient for automatic logging"
    echo ""
}

# Show help
show_help() {
    echo "📖 Lumio Installation Script"
    echo ""
    echo "Usage:"
    echo "  $0 [command]"
    echo ""
    echo "Commands:"
    echo "  install  - Install Lumio in new project (default)"
    echo "  add      - Add Lumio to existing project"
    echo "  help     - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 install    # Install in new project"
    echo "  $0 add        # Add to existing project"
    echo ""
}

# Main script logic
case "${1:-install}" in
    "install")
        install_lumio
        ;;
    "add")
        add_to_existing
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
