import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../plugins/network/network_screen.dart';
import '../plugins/crashes/crash_screen.dart';
import '../plugins/logger/logger_screen.dart';
import '../plugins/network/network_manager.dart';
import '../plugins/crashes/crash_manager.dart';
import '../plugins/crashes/crash_data.dart';
import '../plugins/logger/logger_manager.dart';
import '../plugins/logger/logger_data.dart';

/// Main debugging UI screen that provides access to all Lumio debugging tools
class LumioDebugScreen extends StatefulWidget {
  const LumioDebugScreen({super.key});

  @override
  State<LumioDebugScreen> createState() => _LumioDebugScreenState();
}

class _LumioDebugScreenState extends State<LumioDebugScreen> {
  final NetworkManager _networkManager = NetworkManager();
  final CrashManager _crashManager = CrashManager();
  final LoggerManager _loggerManager = LoggerManager();

  @override
  void initState() {
    super.initState();
    
    // Log the debug screen opening
    _loggerManager.info('Lumio', 'Debug screen opened');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lumio Debug Console'),
        backgroundColor: Colors.indigo.shade100,
        foregroundColor: Colors.indigo.shade800,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _exportAllData,
            icon: const Icon(Icons.download),
            tooltip: 'Export All Data',
          ),
          IconButton(
            onPressed: _clearAllData,
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear All Data',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              color: Colors.indigo.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.developer_mode,
                            color: Colors.indigo.shade700,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lumio Debug Console',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Comprehensive on-device debugging framework',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.indigo.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Quick Stats Overview
            StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 1)),
              builder: (context, snapshot) {
                final networkStats = _networkManager.stats;
                final crashStats = _crashManager.stats;
                final logStats = _loggerManager.stats;
                
                return Row(
                  children: [
                    Expanded(
                      child: _buildQuickStatCard(
                        'Network Calls',
                        '${networkStats.totalRequests}',
                        Icons.network_check,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildQuickStatCard(
                        'Crashes',
                        '${crashStats.totalCrashes}',
                        Icons.bug_report,
                        Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildQuickStatCard(
                        'Logs',
                        '${logStats.totalLogs}',
                        Icons.list_alt,
                        Colors.purple,
                      ),
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Main Debugging Tools
            const Text(
              'Debugging Tools',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Network Plugin
            _buildDebugToolCard(
              title: 'Network Monitor',
              description: 'Monitor HTTP requests, responses, and API calls with detailed inspection',
              icon: Icons.network_check,
              color: Colors.blue,
              onTap: () => _navigateToScreen(const NetworkScreen()),
              features: [
                'Real-time network call monitoring',
                'Request/response inspection',
                'cURL command generation',
                'Performance metrics',
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Crashes Plugin
            _buildDebugToolCard(
              title: 'Crash Monitor',
              description: 'Track crashes, exceptions, and ANR events with detailed stack traces',
              icon: Icons.bug_report,
              color: Colors.red,
              onTap: () => _navigateToScreen(const CrashScreen()),
              features: [
                'Flutter & native crash detection',
                'Exception tracking with breadcrumbs',
                'ANR monitoring (Android)',
                'Detailed crash analysis',
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Logger Plugin
            _buildDebugToolCard(
              title: 'Logger Monitor',
              description: 'Advanced logging with filtering, search, and real-time monitoring',
              icon: Icons.list_alt,
              color: Colors.purple,
              onTap: () => _navigateToScreen(const LoggerScreen()),
              features: [
                'Multi-level logging system',
                'Real-time log streaming',
                'Advanced filtering & search',
                'Session & user tracking',
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _simulateTestData,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Generate Test Data'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade100,
                              foregroundColor: Colors.green.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _exportAllData,
                            icon: const Icon(Icons.download),
                            label: const Text('Export All Data'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade100,
                              foregroundColor: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _clearAllData,
                            icon: const Icon(Icons.clear_all),
                            label: const Text('Clear All Data'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade100,
                              foregroundColor: Colors.red.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showSystemInfo,
                            icon: const Icon(Icons.info),
                            label: const Text('System Info'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade100,
                              foregroundColor: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Footer
            Card(
              color: Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'AppPulse provides comprehensive debugging tools for Flutter applications. '
                        'Monitor network calls, track crashes, and analyze logs in real-time.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugToolCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required List<String> features,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey.shade400,
                    size: 16,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Features list
              ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: color,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToScreen(Widget screen) {
    _loggerManager.info('AppPulse', 'Navigating to ${screen.runtimeType}');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _simulateTestData() async {
    _loggerManager.info('Lumio', 'Generating test data...');
    
    // Generate test network calls
    for (int i = 0; i < 5; i++) {
      final callId = _networkManager.recordRequest(
        method: ['GET', 'POST', 'PUT'][i % 3],
        url: 'https://api.example.com/test/$i',
        headers: {'Content-Type': 'application/json'},
        body: i % 2 == 0 ? '{"test": $i}' : null,
      );
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      _networkManager.recordResponse(
        id: callId,
        statusCode: [200, 201, 400, 404, 500][i % 5],
        headers: {'Server': 'nginx'},
        body: '{"result": "test response $i"}',
      );
    }
    
    // Generate test crashes
    for (int i = 0; i < 3; i++) {
      _crashManager.recordCrash(
        title: 'Test Crash ${i + 1}',
        message: 'This is a simulated crash for testing purposes',
        stackTrace: 'Stack trace line 1\nStack trace line 2\nStack trace line 3',
        type: [CrashType.flutter, CrashType.network, CrashType.custom][i],
        severity: [CrashSeverity.low, CrashSeverity.medium, CrashSeverity.high][i],
      );
    }
    
    // Generate test logs
    final tags = ['UI', 'Network', 'Database', 'Auth'];
    final levels = [LogLevel.info, LogLevel.debug, LogLevel.warning, LogLevel.error];
    
    for (int i = 0; i < 10; i++) {
      _loggerManager.log(
        level: levels[i % levels.length],
        tag: tags[i % tags.length],
        message: 'Test log message ${i + 1}',
        data: {'testId': i, 'timestamp': DateTime.now().millisecondsSinceEpoch},
      );
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test data generated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
    
    _loggerManager.info('Lumio', 'Test data generation completed');
  }

  void _exportAllData() async {
    _loggerManager.info('Lumio', 'Exporting all data...');
    
    final allData = {
      'timestamp': DateTime.now().toIso8601String(),
      'lumio': {
        'version': '0.0.1+1',
        'export_type': 'complete',
      },
      'network': _networkManager.exportAsJson(),
      'crashes': _crashManager.exportAsJson(),
      'logs': _loggerManager.exportAsJson(),
    };
    
    await Clipboard.setData(ClipboardData(text: allData.toString()));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All debugging data exported to clipboard!'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 3),
        ),
      );
    }
    
    _loggerManager.info('Lumio', 'All data exported to clipboard');
  }

  void _clearAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all network calls, crashes, and logs. '
          'This action cannot be undone. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              
              _networkManager.clearAll();
              _crashManager.clearAll();
              _loggerManager.clearAll();
              
              _loggerManager.info('Lumio', 'All debugging data cleared');
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All debugging data cleared!'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showSystemInfo() {
    _loggerManager.info('Lumio', 'Showing system information');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('System Information'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('Lumio Version', '0.0.1+1'),
              _buildInfoRow('Flutter Version', 'Latest'),
              _buildInfoRow('Current User', _loggerManager.currentUserId ?? 'N/A'),
              _buildInfoRow('Session ID', _loggerManager.currentSessionId ?? 'N/A'),
              _buildInfoRow('Debug Mode', 'Enabled'),
              const SizedBox(height: 16),
              const Text(
                'Active Plugins:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('• Network Monitor'),
              const Text('• Crash Monitor'),
              const Text('• Logger Monitor'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
