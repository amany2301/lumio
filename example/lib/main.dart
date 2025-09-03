import 'package:flutter/material.dart';
import 'package:lumio/lumio.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Lumio.initialize();  // 👈 One line only - enables global HTTP hook

  runApp(const LumioExampleApp());
}

class LumioExampleApp extends StatelessWidget {
  const LumioExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lumio Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LumioExampleHomePage(),
    );
  }
}

class LumioExampleHomePage extends StatefulWidget {
  const LumioExampleHomePage({super.key});

  @override
  State<LumioExampleHomePage> createState() => _LumioExampleHomePageState();
}

class _LumioExampleHomePageState extends State<LumioExampleHomePage> {
  String _lastResponse = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lumio Example'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // Debug UI button
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () => Lumio.showDebugUI(context),
            tooltip: 'Open Debug UI',
          ),
          // Clear logs button
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearLogs,
            tooltip: 'Clear All Logs',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lumio Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildStatusRow('Initialized', Lumio.isInitialized),
                    _buildStatusRow('Crash Monitoring', Lumio.isCrashMonitoringEnabled),
                    _buildStatusRow('ANR Monitoring', Lumio.isAnrMonitoringEnabled),
                    _buildStatusRow('Notification Shown', Lumio.isNotificationShown),
                    _buildStatusRow('Global HTTP Hook', Lumio.isGlobalHookEnabled),
                    _buildStatusRow('Auto Detection', Lumio.isAutoDetectionEnabled),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // HTTP Testing section
            const Text(
              'HTTP Testing (Global Hook)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'These calls use the global HTTP hook - no code changes needed!',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _makeGlobalHttpCall,
                    icon: const Icon(Icons.wifi),
                    label: const Text('Global HTTP Call'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _makeMultipleGlobalCalls,
                    icon: const Icon(Icons.list),
                    label: const Text('Multiple Calls'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Manual HTTP Testing section
            const Text(
              'HTTP Testing (Manual)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'These calls use Lumio.httpClient explicitly',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _makeManualHttpCall,
                    icon: const Icon(Icons.api),
                    label: const Text('Manual HTTP Call'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _makeFailedHttpCall,
                    icon: const Icon(Icons.error),
                    label: const Text('Failed Call'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _makeSlowHttpCall,
                    icon: const Icon(Icons.timer),
                    label: const Text('Slow Call'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _makeMultipleManualCalls,
                    icon: const Icon(Icons.list),
                    label: const Text('Multiple Manual'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Dio Testing section
            const Text(
              'Dio Testing',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'These calls use Lumio.dioClient with automatic logging',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _makeDioCall,
                    icon: const Icon(Icons.api),
                    label: const Text('Dio Call'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _makeDioPostCall,
                    icon: const Icon(Icons.send),
                    label: const Text('Dio POST'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _makeDioErrorCall,
                    icon: const Icon(Icons.error),
                    label: const Text('Dio Error'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _makeMultipleDioCalls,
                    icon: const Icon(Icons.list),
                    label: const Text('Multiple Dio'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Crash testing section
            const Text(
              'Crash Testing',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _triggerException,
                    icon: const Icon(Icons.warning),
                    label: const Text('Trigger Exception'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _triggerAssertion,
                    icon: const Icon(Icons.error_outline),
                    label: const Text('Trigger Assertion'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Manual logging section
            const Text(
              'Manual Logging',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _logManualApiResponse,
                    icon: const Icon(Icons.api),
                    label: const Text('Log API Response'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _logManualCrash,
                    icon: const Icon(Icons.bug_report),
                    label: const Text('Log Crash'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _logManualAnr,
                    icon: const Icon(Icons.timer_off),
                    label: const Text('Log ANR'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _exportData,
                    icon: const Icon(Icons.download),
                    label: const Text('Export Data'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Response display
            if (_lastResponse.isNotEmpty) ...[
              const Text(
                'Last Response',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  _lastResponse,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ],
            
            // Instructions
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How to Use:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('1. Tap the notification to open debug UI'),
                    const Text('2. Use the buttons above to test different scenarios'),
                    const Text('3. Check the debug UI to see all logged data'),
                    const Text('4. Use the bug icon in the app bar to open debug UI'),
                    const SizedBox(height: 8),
                    const Text(
                      'Global Hook vs Manual:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text('• Global Hook: Automatically logs ALL HTTP calls'),
                    const Text('• Manual: Use Lumio.httpClient for explicit logging'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: value ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text('$label: ${value ? 'Yes' : 'No'}'),
        ],
      ),
    );
  }

  // Global HTTP Hook Examples (Easy Way)
  Future<void> _makeGlobalHttpCall() async {
    setState(() => _isLoading = true);
    try {
      // This uses the global HTTP hook - no code changes needed!
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/posts/1'),
      );
      setState(() {
        _lastResponse = 'Global Hook - Status: ${response.statusCode}\nBody: ${response.body}';
      });
    } catch (e) {
      setState(() {
        _lastResponse = 'Global Hook - Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _makeMultipleGlobalCalls() async {
    setState(() => _isLoading = true);
    try {
      // These use the global HTTP hook
      final futures = List.generate(3, (index) => 
        http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts/${index + 1}'))
      );
      
      final responses = await Future.wait(futures);
      setState(() {
        _lastResponse = 'Global Hook - Made ${responses.length} HTTP calls successfully';
      });
    } catch (e) {
      setState(() {
        _lastResponse = 'Global Hook - Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Manual HTTP Examples (Explicit Way)
  Future<void> _makeManualHttpCall() async {
    setState(() => _isLoading = true);
    try {
      // This uses Lumio.httpClient explicitly
      final response = await Lumio.httpClient.get(
        Uri.parse('https://jsonplaceholder.typicode.com/posts/2'),
      );
      setState(() {
        _lastResponse = 'Manual - Status: ${response.statusCode}\nBody: ${response.body}';
      });
    } catch (e) {
      setState(() {
        _lastResponse = 'Manual - Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _makeFailedHttpCall() async {
    setState(() => _isLoading = true);
    try {
      final response = await Lumio.httpClient.get(
        Uri.parse('https://httpstat.us/404'),
      );
      setState(() {
        _lastResponse = 'Manual - Status: ${response.statusCode}\nBody: ${response.body}';
      });
    } catch (e) {
      setState(() {
        _lastResponse = 'Manual - Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _makeSlowHttpCall() async {
    setState(() => _isLoading = true);
    try {
      final response = await Lumio.httpClient.get(
        Uri.parse('https://httpbin.org/delay/2'),
      );
      setState(() {
        _lastResponse = 'Manual - Status: ${response.statusCode}\nBody: ${response.body}';
      });
    } catch (e) {
      setState(() {
        _lastResponse = 'Manual - Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _makeMultipleManualCalls() async {
    setState(() => _isLoading = true);
    try {
      final futures = List.generate(3, (index) => 
        Lumio.httpClient.get(Uri.parse('https://jsonplaceholder.typicode.com/posts/${index + 3}'))
      );
      
      final responses = await Future.wait(futures);
      setState(() {
        _lastResponse = 'Manual - Made ${responses.length} HTTP calls successfully';
      });
    } catch (e) {
      setState(() {
        _lastResponse = 'Manual - Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _triggerException() {
    try {
      throw Exception('This is a test exception for Lumio debugging');
    } catch (e) {
      // This will be automatically logged by Lumio's error handler
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exception triggered: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _triggerAssertion() {
    try {
      assert(false, 'This is a test assertion for Lumio debugging');
    } catch (e) {
      // This will be automatically logged by Lumio's error handler
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Assertion triggered: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _logManualApiResponse() {
    Lumio.logApiResponse(
      'https://example.com/manual-api',
      200,
      '{"message": "This is a manually logged API response", "timestamp": "${DateTime.now()}"}',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Manual API response logged'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _logManualCrash() {
    Lumio.logCrash(
      'Manual crash test',
      'This is a manually logged crash for testing purposes\nStack trace would be here...',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Manual crash logged'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _logManualAnr() {
    Lumio.logAnr('Manual ANR test - Main thread blocked for testing');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Manual ANR logged'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _exportData() async {
    try {
      final data = await Lumio.exportAllData();
      if (mounted) {
        setState(() {
          _lastResponse = 'Exported data:\n${data.toString()}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data exported successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _lastResponse = 'Export error: $e';
        });
      }
    }
  }

  Future<void> _clearLogs() async {
    await Lumio.clearAllLogs();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All logs cleared'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  // Dio Examples
  Future<void> _makeDioCall() async {
    setState(() => _isLoading = true);
    try {
      final response = await Lumio.dioClient.get(
        'https://jsonplaceholder.typicode.com/posts/1',
      );
      setState(() {
        _lastResponse = 'Dio - Status: ${response.statusCode}\nData: ${response.data}';
      });
    } catch (e) {
      setState(() {
        _lastResponse = 'Dio - Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _makeDioPostCall() async {
    setState(() => _isLoading = true);
    try {
      final response = await Lumio.dioClient.post(
        'https://jsonplaceholder.typicode.com/posts',
        data: {
          'title': 'Test Post',
          'body': 'This is a test post from Lumio Dio',
          'userId': 1,
        },
      );
      setState(() {
        _lastResponse = 'Dio POST - Status: ${response.statusCode}\nData: ${response.data}';
      });
    } catch (e) {
      setState(() {
        _lastResponse = 'Dio POST - Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _makeDioErrorCall() async {
    setState(() => _isLoading = true);
    try {
      final response = await Lumio.dioClient.get(
        'https://httpstat.us/500',
      );
      setState(() {
        _lastResponse = 'Dio Error - Status: ${response.statusCode}\nData: ${response.data}';
      });
    } catch (e) {
      setState(() {
        _lastResponse = 'Dio Error - Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _makeMultipleDioCalls() async {
    setState(() => _isLoading = true);
    try {
      final futures = List.generate(3, (index) => 
        Lumio.dioClient.get('https://jsonplaceholder.typicode.com/posts/${index + 4}')
      );
      
      final responses = await Future.wait(futures);
      setState(() {
        _lastResponse = 'Dio - Made ${responses.length} calls successfully';
      });
    } catch (e) {
      setState(() {
        _lastResponse = 'Dio - Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Auto Detection Examples
  Future<void> _testAutoDetection() async {
    setState(() => _isLoading = true);
    try {
      // Test auto-detection status
      final autoDetectionEnabled = Lumio.isAutoDetectionEnabled;
      final dioDetected = LumioAutoDetector.dioDetected;
      final httpDetected = LumioAutoDetector.httpDetected;
      final detectedDioInstances = LumioAutoDetector.detectedDioInstances.length;
      final detectedHttpClients = LumioAutoDetector.detectedHttpClients.length;

      setState(() {
        _lastResponse = '''Auto Detection Status:
- Auto Detection Enabled: $autoDetectionEnabled
- Dio Detected: $dioDetected
- HTTP Detected: $httpDetected
- Detected Dio Instances: $detectedDioInstances
- Detected HTTP Clients: $detectedHttpClients''';
      });
    } catch (e) {
      setState(() {
        _lastResponse = 'Auto Detection Test - Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createAndRegisterDio() async {
    setState(() => _isLoading = true);
    try {
      // Create a new Dio instance
      final dio = Dio();
      
      // Register it with Lumio auto-detection
      dio.registerWithLumio();
      
      // Make a call with this Dio instance
      final response = await dio.get('https://jsonplaceholder.typicode.com/posts/5');
      
      setState(() {
        _lastResponse = '''Auto-Registered Dio:
- Status: ${response.statusCode}
- Data: ${response.data}
- Registered: ${LumioAutoDetector.detectedDioInstances.contains(dio)}''';
      });
    } catch (e) {
      setState(() {
        _lastResponse = 'Auto-Registered Dio - Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
