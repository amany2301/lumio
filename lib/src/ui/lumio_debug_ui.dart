import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/lumio_models.dart';
import '../utils/lumio_storage.dart';
import 'dart:async'; // Added for Timer

/// Optimized debug UI with better performance and memory management
class LumioDebugUI extends StatefulWidget {
  const LumioDebugUI({super.key});

  @override
  State<LumioDebugUI> createState() => _LumioDebugUIState();
}

class _LumioDebugUIState extends State<LumioDebugUI> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, List<dynamic>> _cachedData = {};
  final Map<String, DateTime> _lastRefreshTime = {};
  static const Duration _refreshInterval = Duration(seconds: 2);
  Timer? _refreshTimer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _startRefreshTimer();
    _loadInitialData();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  /// Start refresh timer for real-time updates
  void _startRefreshTimer() {
    _refreshTimer = Timer.periodic(_refreshInterval, (timer) {
      if (mounted) {
        _refreshCurrentTab();
      }
    });
  }

  /// Load initial data for current tab
  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    await _loadDataForTab(_getCurrentTabName());
    setState(() => _isLoading = false);
  }

  /// Refresh data for current tab
  Future<void> _refreshCurrentTab() async {
    final tabName = _getCurrentTabName();
    final lastRefresh = _lastRefreshTime[tabName];
    
    if (lastRefresh == null || 
        DateTime.now().difference(lastRefresh) > _refreshInterval) {
      await _loadDataForTab(tabName);
      _lastRefreshTime[tabName] = DateTime.now();
    }
  }

  /// Get current tab name
  String _getCurrentTabName() {
    switch (_tabController.index) {
      case 0: return 'networkCalls';
      case 1: return 'apiResponses';
      case 2: return 'crashes';
      case 3: return 'anrs';
      default: return 'networkCalls';
    }
  }

  /// Load data for specific tab with caching
  Future<void> _loadDataForTab(String tabName) async {
    try {
      List<dynamic> data;
      
      switch (tabName) {
        case 'networkCalls':
          data = await LumioStorage.getNetworkCalls();
          break;
        case 'apiResponses':
          data = await LumioStorage.getApiResponses();
          break;
        case 'crashes':
          data = await LumioStorage.getCrashes();
          break;
        case 'anrs':
          data = await LumioStorage.getAnrs();
          break;
        default:
          data = [];
      }
      
      _cachedData[tabName] = data;
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Lumio: Failed to load data for tab $tabName: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lumio Debug UI'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInitialData,
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearAllLogs,
            tooltip: 'Clear All Logs',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportData,
            tooltip: 'Export Data',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Network Calls'),
            Tab(text: 'API Responses'),
            Tab(text: 'Crashes'),
            Tab(text: 'ANRs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNetworkCallsTab(),
          _buildApiResponsesTab(),
          _buildCrashesTab(),
          _buildAnrsTab(),
        ],
      ),
    );
  }

  /// Build network calls tab with optimized performance
  Widget _buildNetworkCallsTab() {
    final data = _cachedData['networkCalls'] as List<NetworkCallLog>? ?? [];
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (data.isEmpty) {
      return const Center(
        child: Text('No network calls logged yet'),
      );
    }

    return _buildOptimizedListView(
      data: data,
      itemBuilder: (context, index) {
        final log = data[index];
        return NetworkCallCard(log: log);
      },
    );
  }

  /// Build API responses tab with optimized performance
  Widget _buildApiResponsesTab() {
    final data = _cachedData['apiResponses'] as List<ApiResponseLog>? ?? [];
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (data.isEmpty) {
      return const Center(
        child: Text('No API responses logged yet'),
      );
    }

    return _buildOptimizedListView(
      data: data,
      itemBuilder: (context, index) {
        final log = data[index];
        return ApiResponseCard(log: log);
      },
    );
  }

  /// Build crashes tab with optimized performance
  Widget _buildCrashesTab() {
    final data = _cachedData['crashes'] as List<CrashLog>? ?? [];
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (data.isEmpty) {
      return const Center(
        child: Text('No crashes logged yet'),
      );
    }

    return _buildOptimizedListView(
      data: data,
      itemBuilder: (context, index) {
        final log = data[index];
        return CrashCard(log: log);
      },
    );
  }

  /// Build ANRs tab with optimized performance
  Widget _buildAnrsTab() {
    final data = _cachedData['anrs'] as List<AnrLog>? ?? [];
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (data.isEmpty) {
      return const Center(
        child: Text('No ANRs logged yet'),
      );
    }

    return _buildOptimizedListView(
      data: data,
      itemBuilder: (context, index) {
        final log = data[index];
        return AnrCard(log: log);
      },
    );
  }

  /// Build optimized list view with better performance
  Widget _buildOptimizedListView<T>({
    required List<T> data,
    required Widget Function(BuildContext, int) itemBuilder,
  }) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: data.length,
      itemBuilder: itemBuilder,
      // Performance optimizations
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: false,
      cacheExtent: 1000,
    );
  }

  /// Clear all logs
  Future<void> _clearAllLogs() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Logs'),
        content: const Text('Are you sure you want to clear all logs?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await LumioStorage.clearAllLogs();
      _cachedData.clear();
      _lastRefreshTime.clear();
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All logs cleared')),
        );
      }
    }
  }

  /// Export data
  Future<void> _exportData() async {
    try {
      final data = await LumioStorage.exportAllData();
      final jsonString = data.toString();
      
      await Clipboard.setData(ClipboardData(text: jsonString));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data exported to clipboard')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }
}

/// Optimized network call card
class NetworkCallCard extends StatelessWidget {
  final NetworkCallLog log;

  const NetworkCallCard({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ExpansionTile(
        title: Text(
          '${log.method} ${log.url}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${log.formattedDuration} • ${log.formattedTimestamp}',
          style: TextStyle(
            color: _getStatusColor(log.statusColor),
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Method', log.method),
                _buildInfoRow('URL', log.url),
                _buildInfoRow('Duration', log.formattedDuration),
                _buildInfoRow('Timestamp', log.formattedTimestamp),
                if (log.statusCode != null)
                  _buildInfoRow('Status Code', log.statusCode.toString()),
                if (log.error != null)
                  _buildInfoRow('Error', log.error!, isError: true),
                if (log.headers != null && log.headers!.isNotEmpty)
                  _buildInfoRow('Headers', log.headers.toString()),
                if (log.requestBody != null)
                  _buildInfoRow('Request Body', log.requestBody!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'green': return Colors.green;
      case 'red': return Colors.red;
      case 'orange': return Colors.orange;
      default: return Colors.grey;
    }
  }

  Widget _buildInfoRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isError ? Colors.red : null,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Optimized API response card
class ApiResponseCard extends StatelessWidget {
  final ApiResponseLog log;

  const ApiResponseCard({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ExpansionTile(
        title: Text(
          '${log.statusCode} ${log.url}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${log.formattedSize} • ${log.formattedTimestamp}',
          style: TextStyle(
            color: _getStatusColor(log.statusColor),
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('URL', log.url),
                _buildInfoRow('Status Code', log.statusCode.toString()),
                _buildInfoRow('Response Size', log.formattedSize),
                _buildInfoRow('Timestamp', log.formattedTimestamp),
                if (log.headers != null && log.headers!.isNotEmpty)
                  _buildInfoRow('Headers', log.headers.toString()),
                _buildInfoRow('Response Body', log.truncatedBody),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'green': return Colors.green;
      case 'red': return Colors.red;
      case 'orange': return Colors.orange;
      default: return Colors.grey;
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Optimized crash card
class CrashCard extends StatelessWidget {
  final CrashLog log;

  const CrashCard({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      color: Colors.red[50],
      child: ExpansionTile(
        title: Text(
          log.errorType,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        ),
        subtitle: Text(
          log.formattedTimestamp,
          style: const TextStyle(color: Colors.red),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Error Type', log.errorType),
                _buildInfoRow('Timestamp', log.formattedTimestamp),
                _buildInfoRow('Error', log.error, isError: true),
                _buildInfoRow('Stack Trace', log.truncatedStackTrace),
                if (log.metadata != null && log.metadata!.isNotEmpty)
                  _buildInfoRow('Metadata', log.metadata.toString()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isError ? Colors.red : null,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Optimized ANR card
class AnrCard extends StatelessWidget {
  final AnrLog log;

  const AnrCard({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      color: Colors.orange[50],
      child: ExpansionTile(
        title: Text(
          'ANR Detected',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
        ),
        subtitle: Text(
          '${log.formattedDuration} • ${log.formattedTimestamp}',
          style: const TextStyle(color: Colors.orange),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Duration', log.formattedDuration),
                _buildInfoRow('Timestamp', log.formattedTimestamp),
                _buildInfoRow('Message', log.message),
                if (log.threadInfo != null)
                  _buildInfoRow('Thread Info', log.threadInfo!),
                if (log.metadata != null && log.metadata!.isNotEmpty)
                  _buildInfoRow('Metadata', log.metadata.toString()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}
