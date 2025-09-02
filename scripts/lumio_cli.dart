#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

void main(List<String> args) async {
  print('🚀 Lumio CLI - Flutter Debugging Made Easy!');
  print('=============================================\n');

  if (args.isEmpty) {
    _showHelp();
    return;
  }

  final command = args[0];
  
  switch (command) {
    case 'init':
      await _initProject();
      break;
    case 'add':
      await _addToProject();
      break;
    case 'setup':
      await _setupProject();
      break;
    case 'test':
      await _testIntegration();
      break;
    case 'help':
      _showHelp();
      break;
    default:
      print('❌ Unknown command: $command');
      print('Run "dart scripts/lumio_cli.dart help" for available commands');
  }
}

void _showHelp() {
  print('''
📖 Available Commands:

  init     - Initialize Lumio in a new Flutter project
  add      - Add Lumio to existing Flutter project
  setup    - Complete setup with example code
  test     - Test Lumio integration
  help     - Show this help message

📝 Examples:

  # Initialize in new project
  dart scripts/lumio_cli.dart init

  # Add to existing project
  dart scripts/lumio_cli.dart add

  # Complete setup with examples
  dart scripts/lumio_cli.dart setup

  # Test integration
  dart scripts/lumio_cli.dart test
''');
}

Future<void> _initProject() async {
  print('🎯 Initializing Lumio in new Flutter project...\n');
  
  // Check if we're in a Flutter project
  if (!await _isFlutterProject()) {
    print('❌ Error: Not in a Flutter project directory');
    print('Please run this command from your Flutter project root');
    return;
  }

  await _addDependency();
  await _createMainDart();
  await _createExampleScreen();
  await _updateReadme();
  
  print('✅ Lumio initialized successfully!');
  print('\n🚀 Next steps:');
  print('1. Run: flutter pub get');
  print('2. Run: flutter run');
  print('3. Check console for [Lumio] logs');
  print('4. Tap the bug icon to access debug overlay');
}

Future<void> _addToProject() async {
  print('➕ Adding Lumio to existing Flutter project...\n');
  
  if (!await _isFlutterProject()) {
    print('❌ Error: Not in a Flutter project directory');
    return;
  }

  await _addDependency();
  await _updateMainDart();
  
  print('✅ Lumio added successfully!');
  print('\n🚀 Next steps:');
  print('1. Run: flutter pub get');
  print('2. Restart your app');
  print('3. Check console for [Lumio] logs');
}

Future<void> _setupProject() async {
  print('🔧 Complete Lumio setup...\n');
  
  await _initProject();
  await _createExampleFiles();
  
  print('✅ Complete setup finished!');
  print('\n🎉 Your project now includes:');
  print('• Lumio dependency');
  print('• Initialized main.dart');
  print('• Example screens');
  print('• Test buttons for all features');
  print('• Updated README');
}

Future<void> _testIntegration() async {
  print('🧪 Testing Lumio integration...\n');
  
  if (!await _isFlutterProject()) {
    print('❌ Error: Not in a Flutter project directory');
    return;
  }

  final pubspecFile = File('pubspec.yaml');
  if (!await pubspecFile.exists()) {
    print('❌ Error: pubspec.yaml not found');
    return;
  }

  final pubspecContent = await pubspecFile.readAsString();
  if (!pubspecContent.contains('lumio:')) {
    print('❌ Lumio not found in dependencies');
    print('Run: dart scripts/lumio_cli.dart add');
    return;
  }

  final mainFile = File('lib/main.dart');
  if (!await mainFile.exists()) {
    print('❌ Error: lib/main.dart not found');
    return;
  }

  final mainContent = await mainFile.readAsString();
  if (!mainContent.contains('Lumio.initialize')) {
    print('❌ Lumio not initialized in main.dart');
    print('Run: dart scripts/lumio_cli.dart add');
    return;
  }

  print('✅ Lumio integration test passed!');
  print('✅ Dependency found in pubspec.yaml');
  print('✅ Initialization found in main.dart');
  print('\n🚀 Ready to use! Run: flutter run');
}

Future<bool> _isFlutterProject() async {
  final pubspecFile = File('pubspec.yaml');
  if (!await pubspecFile.exists()) return false;
  
  final content = await pubspecFile.readAsString();
  return content.contains('flutter:') || content.contains('sdk: flutter');
}

Future<void> _addDependency() async {
  print('📦 Adding Lumio dependency...');
  
  final pubspecFile = File('pubspec.yaml');
  final content = await pubspecFile.readAsString();
  
  if (content.contains('lumio:')) {
    print('✅ Lumio dependency already exists');
    return;
  }

  // Find dependencies section
  final lines = content.split('\n');
  int dependenciesIndex = -1;
  
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].trim() == 'dependencies:') {
      dependenciesIndex = i;
      break;
    }
  }

  if (dependenciesIndex == -1) {
    print('❌ Error: Could not find dependencies section');
    return;
  }

  // Add lumio dependency
  lines.insert(dependenciesIndex + 1, '  lumio: ^0.0.1');
  
  await pubspecFile.writeAsString(lines.join('\n'));
  print('✅ Added lumio: ^0.0.1 to dependencies');
}

Future<void> _createMainDart() async {
  print('📝 Creating main.dart with Lumio...');
  
  final mainFile = File('lib/main.dart');
  if (await mainFile.exists()) {
    print('⚠️  lib/main.dart already exists, skipping...');
    return;
  }

  final mainContent = '''import 'package:flutter/material.dart';
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
        SnackBar(content: Text('❌ Error: \$e')),
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
''';

  await mainFile.writeAsString(mainContent);
  print('✅ Created lib/main.dart with Lumio integration');
}

Future<void> _updateMainDart() async {
  print('📝 Updating main.dart with Lumio...');
  
  final mainFile = File('lib/main.dart');
  if (!await mainFile.exists()) {
    print('❌ Error: lib/main.dart not found');
    return;
  }

  final content = await mainFile.readAsString();
  
  if (content.contains('Lumio.initialize')) {
    print('✅ Lumio already initialized in main.dart');
    return;
  }

  // Add import
  String newContent = content;
  if (!content.contains("import 'package:lumio/lumio.dart';")) {
    newContent = "import 'package:lumio/lumio.dart';\n" + newContent;
  }

  // Add initialization
  if (content.contains('void main()')) {
    newContent = newContent.replaceFirst(
      'void main() {',
      '''void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Lumio monitoring
  await Lumio.initialize(
    enableCrashMonitoring: true,
    enableAnrMonitoring: true,
    enableDebugOverlay: true,
  );
  
  ''',
    );
    
    newContent = newContent.replaceFirst('runApp(', '  runApp(');
  }

  await mainFile.writeAsString(newContent);
  print('✅ Updated main.dart with Lumio initialization');
}

Future<void> _createExampleScreen() async {
  print('📱 Creating example screen...');
  
  final exampleDir = Directory('lib/screens');
  if (!await exampleDir.exists()) {
    await exampleDir.create(recursive: true);
  }

  final exampleFile = File('lib/screens/lumio_example_screen.dart');
  if (await exampleFile.exists()) {
    print('⚠️  Example screen already exists, skipping...');
    return;
  }

  final exampleContent = '''import 'package:flutter/material.dart';
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
        _statusMessage = 'Network call failed: \$e';
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
        _statusMessage = 'Crash logging failed: \$e';
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
''';

  await exampleFile.writeAsString(exampleContent);
  print('✅ Created example screen at lib/screens/lumio_example_screen.dart');
}

Future<void> _createExampleFiles() async {
  print('📄 Creating additional example files...');
  
  // Create a simple test file
  final testFile = File('test/lumio_test.dart');
  if (!await testFile.exists()) {
    final testContent = '''import 'package:flutter_test/flutter_test.dart';
import 'package:lumio/lumio.dart';

void main() {
  group('Lumio Tests', () {
    test('should initialize without errors', () async {
      // This is a basic test to ensure Lumio can be imported
      expect(Lumio.isInitialized, isFalse);
    });
  });
}
''';
    
    final testDir = Directory('test');
    if (!await testDir.exists()) {
      await testDir.create();
    }
    
    await testFile.writeAsString(testContent);
    print('✅ Created test file at test/lumio_test.dart');
  }
}

Future<void> _updateReadme() async {
  print('📖 Updating README...');
  
  final readmeFile = File('README.md');
  if (!await readmeFile.exists()) {
    print('⚠️  README.md not found, creating new one...');
    await _createReadme();
    return;
  }

  final content = await readmeFile.readAsString();
  
  if (content.contains('Lumio')) {
    print('✅ README already mentions Lumio');
    return;
  }

  // Add Lumio section to existing README
  final lumioSection = '''

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
''';

  final newContent = content + lumioSection;
  await readmeFile.writeAsString(newContent);
  print('✅ Updated README with Lumio information');
}

Future<void> _createReadme() async {
  final readmeContent = '''# My Flutter App

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
''';

  await File('README.md').writeAsString(readmeContent);
  print('✅ Created README.md with Lumio information');
}
