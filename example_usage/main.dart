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
        title: 'Lumio Usage Example',
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
      // This will be automatically logged by Lumio
      final response = await _httpClient.get('https://jsonplaceholder.typicode.com/posts/1');
      
      setState(() {
        _statusMessage = 'Network call completed! Check console for logs.';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Network call successful!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _statusMessage = 'Network call failed: $e';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Network call failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _testPostRequest() async {
    setState(() {
      _statusMessage = 'Making POST request...';
    });
    
    try {
      // POST request with automatic logging
      final response = await _httpClient.post(
        'https://jsonplaceholder.typicode.com/posts',
        body: {
          'title': 'Test Post from Lumio',
          'body': 'This is a test post created using Lumio HTTP client',
          'userId': 1,
        },
      );
      
      setState(() {
        _statusMessage = 'POST request completed! Check console for logs.';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ POST request successful!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _statusMessage = 'POST request failed: $e';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ POST request failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _testManualLogging() async {
    setState(() {
      _statusMessage = 'Testing manual logging...';
    });
    
    try {
      // Manual network call logging
      await Lumio.logNetworkCall('GET', 'https://api.example.com/test', 150);
      
      // Manual API response logging
      await Lumio.logApiResponse(
        'https://api.example.com/test',
        200,
        '{"message": "Test response", "status": "success"}',
      );
      
      setState(() {
        _statusMessage = 'Manual logging completed! Check console for logs.';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Manual logging successful!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _statusMessage = 'Manual logging failed: $e';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Manual logging failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _testCrashLogging() async {
    setState(() {
      _statusMessage = 'Testing crash logging...';
    });
    
    try {
      // Manually log a crash
      await Lumio.logCrash(
        'Test Exception: This is a simulated crash for testing',
        '''
#0      _MyHomePageState._testCrashLogging (package:example_usage/main.dart:150:7)
#1      _InkResponseState._handleTap (package:flutter/src/material/ink_well.dart:1005:21)
#2      GestureRecognizer.invokeCallback (package:flutter/src/gestures/recognizer.dart:253:24)
        ''',
      );
      
      setState(() {
        _statusMessage = 'Crash logged successfully! Check console for logs.';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Crash logged successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _statusMessage = 'Crash logging failed: $e';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Crash logging failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _simulateActualCrash() {
    setState(() {
      _statusMessage = 'Simulating actual crash...';
    });
    
    // This will trigger the crash monitoring
    Future.delayed(Duration(seconds: 1), () {
      throw Exception('This is a simulated crash for testing Lumio crash monitoring');
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lumio Usage Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.bug_report),
            onPressed: () => Lumio.toggleDebugOverlay(),
            tooltip: 'Toggle Debug Overlay',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Lumio Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Initialized: ${Lumio.isInitialized ? "✅" : "❌"}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Crash Monitoring: ${Lumio.isCrashMonitoringEnabled ? "✅" : "❌"}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'ANR Monitoring: ${Lumio.isAnrMonitoringEnabled ? "✅" : "❌"}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Debug Overlay: ${Lumio.isDebugOverlayEnabled ? "✅" : "❌"}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Status Message
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
            
            SizedBox(height: 24),
            
            // Test Buttons
            Text(
              'Test Lumio Features:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            
            SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: _testNetworkCall,
              icon: Icon(Icons.network_check),
              label: Text('Test GET Request'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            
            SizedBox(height: 8),
            
            ElevatedButton.icon(
              onPressed: _testPostRequest,
              icon: Icon(Icons.send),
              label: Text('Test POST Request'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            
            SizedBox(height: 8),
            
            ElevatedButton.icon(
              onPressed: _testManualLogging,
              icon: Icon(Icons.edit),
              label: Text('Test Manual Logging'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
            
            SizedBox(height: 8),
            
            ElevatedButton.icon(
              onPressed: _testCrashLogging,
              icon: Icon(Icons.bug_report),
              label: Text('Test Crash Logging'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
            ),
            
            SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: _simulateActualCrash,
              icon: Icon(Icons.warning),
              label: Text('⚠️ Simulate Actual Crash'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
            
            SizedBox(height: 24),
            
            // Instructions
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        SizedBox(width: 8),
                        Text(
                          'How to View Logs',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('• Check your IDE console for [Lumio] prefixed logs'),
                    Text('• Use the debug overlay button in the app bar'),
                    Text('• Network calls are automatically logged'),
                    Text('• Crashes are automatically captured'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
