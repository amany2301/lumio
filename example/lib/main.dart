import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:lumio/lumio.dart';
import 'log_viewer_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Lumio debugging framework
  await Lumio.initialize(
    enableCrashMonitoring: true,
    enableAnrMonitoring: true,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _statusMessage = 'Lumio initialized';
  final LumioHttpClient _httpClient = LumioHttpClient();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    _httpClient.close();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await Lumio.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  void _testHttpLogging() async {
    setState(() {
      _statusMessage = 'Testing HTTP logging...';
    });

    try {
      // Simulate an HTTP request
      await Lumio.logHttpRequest(
        method: 'GET',
        url: 'https://jsonplaceholder.typicode.com/posts/1',
        headers: {'Content-Type': 'application/json'},
        body: null,
      );

      // Simulate an HTTP response
      await Lumio.logHttpResponse(
        url: 'https://jsonplaceholder.typicode.com/posts/1',
        statusCode: 200,
        body: '{"userId": 1, "id": 1, "title": "Test Post", "body": "This is a test post body"}',
        headers: {'Content-Type': 'application/json'},
        durationMs: 250,
      );

      setState(() {
        _statusMessage = 'HTTP logging test completed!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'HTTP logging failed: $e';
      });
    }
  }

  void _testCrashLogging() async {
    setState(() {
      _statusMessage = 'Testing crash logging...';
    });

    try {
      // Simulate a crash log
      await Lumio.logCrash(
        'Test Exception: Division by zero',
        '''
#0      _MyAppState._testCrashLogging (package:lumio_example/main.dart:95:7)
#1      _InkResponseState._handleTap (package:flutter/src/material/ink_well.dart:1005:21)
#2      GestureRecognizer.invokeCallback (package:flutter/src/gestures/recognizer.dart:253:24)
        ''',
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

  void _testAnrLogging() async {
    setState(() {
      _statusMessage = 'Testing ANR logging...';
    });

    try {
      // Simulate an ANR log (Android only)
      await Lumio.logAnr('Main thread blocked for 5000ms during heavy computation');

      setState(() {
        _statusMessage = Platform.isAndroid 
          ? 'ANR logged successfully!' 
          : 'ANR logging called (Android only feature)';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'ANR logging failed: $e';
      });
    }
  }

  void _testHttpClient() async {
    setState(() {
      _statusMessage = 'Testing HTTP client with auto-logging...';
    });

    try {
      // This will automatically log both the HTTP request and response
      await _httpClient.get('https://jsonplaceholder.typicode.com/posts/1');
      
      setState(() {
        _statusMessage = 'HTTP client test completed! Check logs for automatic logging.';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'HTTP client test failed: $e';
      });
    }
  }

  void _simulateActualCrash() {
    setState(() {
      _statusMessage = 'Simulating actual crash...';
    });

    // This will trigger the crash monitoring
    Timer(const Duration(seconds: 1), () {
      throw Exception('This is a simulated crash for testing Lumio crash monitoring');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lumio Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: LumioApp(
        enableDebugOverlay: true,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Lumio Debug Example'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            actions: [
              Builder(
                builder: (context) => IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LogViewerScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility),
                  tooltip: 'View Logs',
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Platform: $_platformVersion',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Crash Monitoring: ${Lumio.isCrashMonitoringEnabled ? "Enabled" : "Disabled"}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          'ANR Monitoring: ${Lumio.isAnrMonitoringEnabled ? "Enabled" : "Disabled"}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _statusMessage,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Test Lumio Debug Features:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _testHttpLogging,
                  child: const Text('Test HTTP Request/Response Logging'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _testCrashLogging,
                  child: const Text('Test Crash Logging'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _testAnrLogging,
                  child: const Text('Test ANR Logging'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _testHttpClient,
                  child: const Text('Test HTTP Client (Auto-logging)'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _simulateActualCrash,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('⚠️ Simulate Actual Crash'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
