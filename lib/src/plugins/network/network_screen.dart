import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'network_manager.dart';
import 'network_data.dart';
import 'network_detail_screen.dart';

class NetworkScreen extends StatefulWidget {
  const NetworkScreen({super.key});

  @override
  State<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen> with TickerProviderStateMixin {
  final NetworkManager _networkManager = NetworkManager();
  final TextEditingController _searchController = TextEditingController();
  
  List<NetworkCall> _filteredCalls = [];
  String? _selectedMethod;
  bool? _selectedSuccess;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _filteredCalls = _networkManager.allCalls;
    
    // Listen to new network calls
    _networkManager.networkCallStream.listen((_) {
      if (mounted) {
        _applyFilters();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      var calls = _networkManager.allCalls;
      
      // Apply search filter
      if (_searchController.text.isNotEmpty) {
        calls = _networkManager.searchCalls(_searchController.text);
      }
      
      // Apply method filter
      if (_selectedMethod != null) {
        calls = calls.where((call) => call.method == _selectedMethod).toList();
      }
      
      // Apply success filter
      if (_selectedSuccess != null) {
        calls = calls.where((call) => call.isSuccess == _selectedSuccess).toList();
      }
      
      _filteredCalls = calls;
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedMethod = null;
      _selectedSuccess = null;
      _filteredCalls = _networkManager.allCalls;
    });
  }

  void _exportData() async {
    final data = _networkManager.exportAsJson();
    final jsonString = data.toString();
    
    await Clipboard.setData(ClipboardData(text: jsonString));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Network data exported to clipboard!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Monitor'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Requests', icon: Icon(Icons.list)),
            Tab(text: 'Statistics', icon: Icon(Icons.analytics)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _exportData,
            icon: const Icon(Icons.download),
            tooltip: 'Export Data',
          ),
          IconButton(
            onPressed: () {
              _networkManager.clearAll();
              _applyFilters();
            },
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear All',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestsTab(),
          _buildStatisticsTab(),
        ],
      ),
    );
  }

  Widget _buildRequestsTab() {
    return Column(
      children: [
        // Search and Filter Bar
        Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.grey.shade100,
          child: Column(
            children: [
              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search URLs, request/response content...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (_) => _applyFilters(),
              ),
              
              const SizedBox(height: 8),
              
              // Filter Chips
              Wrap(
                spacing: 8,
                children: [
                  // Method Filter
                  FilterChip(
                    label: Text(_selectedMethod ?? 'All Methods'),
                    selected: _selectedMethod != null,
                    onSelected: (selected) {
                      _showMethodFilter();
                    },
                  ),
                  
                  // Success Filter
                  FilterChip(
                    label: Text(_selectedSuccess == null 
                      ? 'All Status' 
                      : _selectedSuccess! ? 'Success' : 'Failed'),
                    selected: _selectedSuccess != null,
                    onSelected: (selected) {
                      _showSuccessFilter();
                    },
                  ),
                  
                  // Clear Filters
                  if (_selectedMethod != null || _selectedSuccess != null || _searchController.text.isNotEmpty)
                    ActionChip(
                      label: const Text('Clear Filters'),
                      onPressed: _clearFilters,
                      backgroundColor: Colors.red.shade100,
                    ),
                ],
              ),
            ],
          ),
        ),
        
        // Network Calls List
        Expanded(
          child: _filteredCalls.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.network_check, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No network calls found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Make some API calls to see them here',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: _filteredCalls.length,
                itemBuilder: (context, index) {
                  final call = _filteredCalls[index];
                  return _buildNetworkCallTile(call);
                },
              ),
        ),
      ],
    );
  }

  Widget _buildStatisticsTab() {
    return StreamBuilder<NetworkStats>(
      stream: _networkManager.statsStream,
      initialData: _networkManager.stats,
      builder: (context, snapshot) {
        final stats = snapshot.data!;
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview Cards
              Row(
                children: [
                  Expanded(child: _buildStatCard('Total Requests', stats.totalRequests.toString(), Colors.blue)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildStatCard('Success Rate', '${stats.successRate.toStringAsFixed(1)}%', Colors.green)),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Expanded(child: _buildStatCard('Failed', stats.failedRequests.toString(), Colors.red)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildStatCard('Pending', stats.pendingRequests.toString(), Colors.orange)),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Detailed Stats
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detailed Statistics',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildStatRow('Average Response Time', '${stats.averageResponseTime.toStringAsFixed(0)} ms'),
                      _buildStatRow('Total Data Transferred', _formatBytes(stats.totalDataTransferred)),
                      _buildStatRow('Successful Requests', '${stats.successfulRequests}'),
                      _buildStatRow('Failed Requests', '${stats.failedRequests}'),
                      _buildStatRow('Failure Rate', '${stats.failureRate.toStringAsFixed(1)}%'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _buildNetworkCallTile(NetworkCall call) {
    final statusColor = call.hasError ? Colors.red : 
                       call.isSuccess ? Colors.green : 
                       call.isCompleted ? Colors.orange : Colors.grey;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 32,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text(
              call.method,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ),
        title: Text(
          call.url,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                if (call.statusCode != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${call.statusCode}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (call.duration != null) ...[
                  Text(
                    '${call.duration}ms',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  _formatTime(call.requestTime),
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
        trailing: call.isCompleted 
          ? Icon(
              call.isSuccess ? Icons.check_circle : Icons.error,
              color: statusColor,
              size: 20,
            )
          : const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NetworkDetailScreen(networkCall: call),
            ),
          );
        },
      ),
    );
  }

  void _showMethodFilter() {
    final methods = ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'HEAD', 'OPTIONS'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Methods'),
              selected: _selectedMethod == null,
              onTap: () {
                setState(() => _selectedMethod = null);
                Navigator.pop(context);
                _applyFilters();
              },
            ),
            ...methods.map((method) => ListTile(
              title: Text(method),
              selected: _selectedMethod == method,
              onTap: () {
                setState(() => _selectedMethod = method);
                Navigator.pop(context);
                _applyFilters();
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showSuccessFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Status'),
              selected: _selectedSuccess == null,
              onTap: () {
                setState(() => _selectedSuccess = null);
                Navigator.pop(context);
                _applyFilters();
              },
            ),
            ListTile(
              title: const Text('Success Only'),
              selected: _selectedSuccess == true,
              onTap: () {
                setState(() => _selectedSuccess = true);
                Navigator.pop(context);
                _applyFilters();
              },
            ),
            ListTile(
              title: const Text('Failed Only'),
              selected: _selectedSuccess == false,
              onTap: () {
                setState(() => _selectedSuccess = false);
                Navigator.pop(context);
                _applyFilters();
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}
