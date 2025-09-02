import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lumio/lumio.dart';

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

  void _makeHttpGetRequest() async {
    try {
      // This will generate detailed logs with cURL commands
      LumioLogger.info('Making HTTP GET request to JSONPlaceholder...');
      
      await _httpClient.get('https://jsonplaceholder.typicode.com/posts/1');
      
      LumioLogger.success('HTTP GET request completed successfully!');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('HTTP GET request completed! Check console for detailed logs with cURL command.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      LumioLogger.error('HTTP GET request failed: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('HTTP GET request failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _makeHttpPostRequest() async {
    try {
      LumioLogger.info('Making HTTP POST request...');
      
      await _httpClient.post(
        'https://jsonplaceholder.typicode.com/posts',
        body: {
          'title': 'Test Post from Lumio',
          'body': 'This is a test post created using Lumio HTTP client',
          'userId': 1,
        },
      );
      
      LumioLogger.success('HTTP POST request completed!');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('HTTP POST request completed! Check console for cURL command.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      LumioLogger.error('HTTP POST request failed: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('HTTP POST request failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _simulateHttpError() async {
    try {
      LumioLogger.warning('Simulating HTTP error...');
      
      await _httpClient.get('https://httpstat.us/500');
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('HTTP error simulated! Check console for error logs.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _copyInstructions() {
    const instructions = '''
🔍 HOW TO VIEW YOUR HTTP DEBUG LOGS:

📱 iOS (Recommended):
1. Open Xcode
2. Go to Window → Devices and Simulators
3. Select your device/simulator
4. Click "Open Console"
5. Filter by "[Lumio]" to see only your logs

💻 Terminal/VS Code:
1. Run: flutter logs
2. Look for [Lumio] entries
3. You'll see detailed HTTP requests/responses and cURL commands

🎯 What You'll See:
✅ Complete HTTP requests with headers and body
✅ HTTP responses with status codes and JSON formatting
✅ cURL commands you can copy and paste
✅ Request duration and performance metrics
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
        title: const Text('HTTP Debug Logs'),
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
                          'HTTP Debug Logging',
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
                      'Lumio provides detailed HTTP debugging with cURL commands. Here\'s how to view them:',
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
              'Test HTTP Requests:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: _makeHttpGetRequest,
              icon: const Icon(Icons.get_app),
              label: const Text('Test HTTP GET Request'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            
            const SizedBox(height: 8),
            
            ElevatedButton.icon(
              onPressed: _makeHttpPostRequest,
              icon: const Icon(Icons.send),
              label: const Text('Test HTTP POST Request'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            
            const SizedBox(height: 8),
            
            ElevatedButton.icon(
              onPressed: _simulateHttpError,
              icon: const Icon(Icons.error_outline),
              label: const Text('Simulate HTTP Error (500)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
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
                    const Text('✅ Complete HTTP requests with headers and body'),
                    const Text('✅ HTTP responses with status codes and JSON formatting'),
                    const Text('✅ cURL commands you can copy and paste'),
                    const Text('✅ Request duration and performance metrics'),
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
