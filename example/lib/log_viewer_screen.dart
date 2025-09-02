import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lumio/lumio.dart';
import 'package:lumio/src/interceptors/lumio_http_interceptor.dart';
import 'package:lumio/src/utils/lumio_logger.dart';

class LogViewerScreen extends StatefulWidget {
  const LogViewerScreen({super.key});

  @override
  State<LogViewerScreen> createState() => _LogViewerScreenState();
}

class _LogViewerScreenState extends State<LogViewerScreen> {
  final LumioHttpClient _httpClient = LumioHttpClient();

  @override
  void dispose() {
    _httpClient.close();
    super.dispose();
  }

  void _makeApiCall() async {
    try {
      // This will generate detailed logs with cURL commands
      LumioLogger.info('Making API call to JSONPlaceholder...');
      
      await _httpClient.get('https://jsonplaceholder.typicode.com/posts/1');
      
      LumioLogger.success('API call completed successfully!');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('API call completed! Check console for detailed logs with cURL command.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      LumioLogger.error('API call failed: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('API call failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _makePostRequest() async {
    try {
      LumioLogger.info('Making POST request...');
      
      await _httpClient.post(
        'https://jsonplaceholder.typicode.com/posts',
        body: {
          'title': 'Test Post from Lumio',
          'body': 'This is a test post created using Lumio HTTP client',
          'userId': 1,
        },
      );
      
      LumioLogger.success('POST request completed!');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('POST request completed! Check console for cURL command.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      LumioLogger.error('POST request failed: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('POST request failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _simulateError() async {
    try {
      LumioLogger.warning('Simulating network error...');
      
      await _httpClient.get('https://httpstat.us/500');
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error simulated! Check console for error logs.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _copyInstructions() {
    const instructions = '''
🔍 HOW TO VIEW YOUR API LOGS:

📱 iOS (Recommended):
1. Open Xcode
2. Go to Window → Devices and Simulators
3. Select your device/simulator
4. Click "Open Console"
5. Filter by "[Lumio]" to see only your logs

💻 Terminal/VS Code:
1. Run: flutter logs
2. Look for [Lumio] entries
3. You'll see detailed API responses and cURL commands

🎯 What You'll See:
✅ Complete API responses with JSON formatting
✅ Request/Response headers
✅ cURL commands you can copy and paste
✅ Request duration and status codes
✅ Error logs with stack traces

🔧 Customize Logging:
LumioLogger.setDetailedLogging(false); // Disable detailed logs
LumioLogger.setCurlGeneration(false);  // Disable cURL generation
''';

    Clipboard.setData(const ClipboardData(text: instructions));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Instructions copied to clipboard!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Viewer Guide'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _copyInstructions,
            icon: const Icon(Icons.copy),
            tooltip: 'Copy Instructions',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                        const SizedBox(width: 8),
                        Text(
                          'How to View Your API Logs',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Lumio provides detailed logging with cURL commands. Here\'s how to view them:',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📱 For iOS (Recommended):',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('1. Open Xcode'),
                    const Text('2. Go to Window → Devices and Simulators'),
                    const Text('3. Select your device/simulator'),
                    const Text('4. Click "Open Console"'),
                    const Text('5. Filter by "[Lumio]"'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💻 For Terminal/VS Code:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('1. Run: flutter logs'),
                    const Text('2. Look for [Lumio] entries'),
                    const Text('3. Copy cURL commands to test in terminal'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Test API Calls:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: _makeApiCall,
              icon: const Icon(Icons.get_app),
              label: const Text('Test GET Request'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            
            const SizedBox(height: 8),
            
            ElevatedButton.icon(
              onPressed: _makePostRequest,
              icon: const Icon(Icons.send),
              label: const Text('Test POST Request'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            
            const SizedBox(height: 8),
            
            ElevatedButton.icon(
              onPressed: _simulateError,
              icon: const Icon(Icons.error_outline),
              label: const Text('Simulate Error (500)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NetworkScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.network_check),
              label: const Text('🚀 Open Network Monitor'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const SizedBox(height: 8),
            
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CrashScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.bug_report),
              label: const Text('💥 Open Crash Monitor'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const SizedBox(height: 8),
            
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoggerScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.list_alt),
              label: const Text('📝 Open Logger Monitor'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: Colors.amber.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'What You\'ll See:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('✅ Complete API responses with JSON formatting'),
                    const Text('✅ Request/Response headers'),
                    const Text('✅ cURL commands you can copy and paste'),
                    const Text('✅ Request duration and status codes'),
                    const Text('✅ Error logs with stack traces'),
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
