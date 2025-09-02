import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'crash_manager.dart';
import 'crash_data.dart';
import 'crash_detail_screen.dart';

class CrashScreen extends StatefulWidget {
  const CrashScreen({super.key});

  @override
  State<CrashScreen> createState() => _CrashScreenState();
}

class _CrashScreenState extends State<CrashScreen> with TickerProviderStateMixin {
  final CrashManager _crashManager = CrashManager();
  final TextEditingController _searchController = TextEditingController();
  
  List<CrashReport> _filteredCrashes = [];
  CrashType? _selectedType;
  CrashSeverity? _selectedSeverity;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _filteredCrashes = _crashManager.allCrashes;
    
    // Listen to new crashes
    _crashManager.crashStream.listen((_) {
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
      var crashes = _crashManager.allCrashes;
      
      // Apply search filter
      if (_searchController.text.isNotEmpty) {
        crashes = _crashManager.searchCrashes(_searchController.text);
      }
      
      // Apply type filter
      if (_selectedType != null) {
        crashes = crashes.where((crash) => crash.type == _selectedType).toList();
      }
      
      // Apply severity filter
      if (_selectedSeverity != null) {
        crashes = crashes.where((crash) => crash.severity == _selectedSeverity).toList();
      }
      
      _filteredCrashes = crashes;
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedType = null;
      _selectedSeverity = null;
      _filteredCrashes = _crashManager.allCrashes;
    });
  }

  void _exportData() async {
    final data = _crashManager.exportAsJson();
    final jsonString = data.toString();
    
    await Clipboard.setData(ClipboardData(text: jsonString));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Crash data exported to clipboard!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _simulateCrash() {
    _crashManager.recordCrash(
      title: 'Simulated Crash',
      message: 'This is a test crash to demonstrate the crash monitoring functionality',
      stackTrace: '''
#0      _CrashScreenState._simulateCrash (package:app_pulse_example/crash_screen.dart:87:5)
#1      _InkResponseState.handleTap (package:flutter/src/material/ink_well.dart:1203:21)
#2      GestureRecognizer.invokeCallback (package:flutter/src/gestures/recognizer.dart:345:24)
#3      TapGestureRecognizer.handleTapUp (package:flutter/src/gestures/tap.dart:737:11)
#4      BaseTapGestureRecognizer._checkUp (package:flutter/src/gestures/tap.dart:362:5)
#5      BaseTapGestureRecognizer.acceptGesture (package:flutter/src/gestures/tap.dart:332:7)
      ''',
      type: CrashType.flutter,
      severity: CrashSeverity.medium,
      context: {
        'screen': 'CrashScreen',
        'action': 'simulate_crash',
        'timestamp': DateTime.now().toIso8601String(),
      },
      customData: {
        'isSimulated': true,
        'userTriggered': true,
      },
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Crash simulated! Check the crashes list.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crash Monitor'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Crashes', icon: Icon(Icons.bug_report)),
            Tab(text: 'Statistics', icon: Icon(Icons.analytics)),
            Tab(text: 'Breadcrumbs', icon: Icon(Icons.timeline)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _simulateCrash,
            icon: const Icon(Icons.play_arrow),
            tooltip: 'Simulate Crash',
          ),
          IconButton(
            onPressed: _exportData,
            icon: const Icon(Icons.download),
            tooltip: 'Export Data',
          ),
          IconButton(
            onPressed: () {
              _crashManager.clearAll();
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
          _buildCrashesTab(),
          _buildStatisticsTab(),
          _buildBreadcrumbsTab(),
        ],
      ),
    );
  }

  Widget _buildCrashesTab() {
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
                  hintText: 'Search crashes, messages, stack traces...',
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
                  // Type Filter
                  FilterChip(
                    label: Text(_selectedType?.name.toUpperCase() ?? 'All Types'),
                    selected: _selectedType != null,
                    onSelected: (selected) {
                      _showTypeFilter();
                    },
                  ),
                  
                  // Severity Filter
                  FilterChip(
                    label: Text(_selectedSeverity?.name.toUpperCase() ?? 'All Severities'),
                    selected: _selectedSeverity != null,
                    onSelected: (selected) {
                      _showSeverityFilter();
                    },
                  ),
                  
                  // Clear Filters
                  if (_selectedType != null || _selectedSeverity != null || _searchController.text.isNotEmpty)
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
        
        // Crashes List
        Expanded(
          child: _filteredCrashes.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bug_report, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No crashes found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your app is running smoothly! 🎉',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: _filteredCrashes.length,
                itemBuilder: (context, index) {
                  final crash = _filteredCrashes[index];
                  return _buildCrashTile(crash);
                },
              ),
        ),
      ],
    );
  }

  Widget _buildStatisticsTab() {
    return StreamBuilder<CrashStats>(
      stream: _crashManager.statsStream,
      initialData: _crashManager.stats,
      builder: (context, snapshot) {
        final stats = snapshot.data!;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview Cards
              Row(
                children: [
                  Expanded(child: _buildStatCard('Total Crashes', stats.totalCrashes.toString(), Colors.red)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildStatCard('Crash Free Rate', '${stats.crashFreeRate.toStringAsFixed(1)}%', Colors.green)),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Expanded(child: _buildStatCard('Flutter', stats.flutterCrashes.toString(), Colors.blue)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildStatCard('Native', stats.nativeCrashes.toString(), Colors.orange)),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Crash Types Breakdown
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Crash Types Breakdown',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildStatRow('Flutter Crashes', '${stats.flutterCrashes}', Colors.blue),
                      _buildStatRow('Native Crashes', '${stats.nativeCrashes}', Colors.orange),
                      _buildStatRow('ANR Events', '${stats.anrEvents}', Colors.red),
                      _buildStatRow('Network Errors', '${stats.networkErrors}', Colors.purple),
                      _buildStatRow('Memory Issues', '${stats.memoryIssues}', Colors.brown),
                      _buildStatRow('Custom Errors', '${stats.customErrors}', Colors.grey),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Severity Breakdown
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Severity Breakdown',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      ...stats.severityBreakdown.entries.map((entry) =>
                        _buildStatRow(
                          entry.key.name.toUpperCase(),
                          '${entry.value}',
                          _getSeverityColor(entry.key),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Additional Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Additional Information',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildInfoRow('Most Common Type', stats.mostCommonCrashType.name.toUpperCase()),
                      _buildInfoRow('Crash Rate', '${stats.crashRate.toStringAsFixed(1)}%'),
                      if (stats.lastCrashTime != null)
                        _buildInfoRow('Last Crash', _formatDateTime(stats.lastCrashTime!)),
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

  Widget _buildBreadcrumbsTab() {
    final breadcrumbs = _crashManager.allBreadcrumbs;
    
    return breadcrumbs.isEmpty
      ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timeline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No breadcrumbs recorded',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Breadcrumbs help track user actions leading to crashes',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        )
      : ListView.builder(
          itemCount: breadcrumbs.length,
          itemBuilder: (context, index) {
            final breadcrumb = breadcrumbs[index];
            return _buildBreadcrumbTile(breadcrumb);
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

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Text(value, style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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

  Widget _buildCrashTile(CrashReport crash) {
    final severityColor = _getSeverityColor(crash.severity);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: severityColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: severityColor.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text(
              crash.icon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        title: Text(
          crash.title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              crash.summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    crash.severity.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: severityColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  crash.type.name.toUpperCase(),
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTime(crash.timestamp),
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade400,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CrashDetailScreen(crash: crash),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBreadcrumbTile(CrashBreadcrumb breadcrumb) {
    final levelColor = _getBreadcrumbLevelColor(breadcrumb.level);

    return ListTile(
      leading: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: levelColor,
          shape: BoxShape.circle,
        ),
      ),
      title: Text(
        breadcrumb.message,
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: Text(
        '${breadcrumb.category} • ${_formatTime(breadcrumb.timestamp)}',
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      dense: true,
    );
  }

  void _showTypeFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Types'),
              selected: _selectedType == null,
              onTap: () {
                setState(() => _selectedType = null);
                Navigator.pop(context);
                _applyFilters();
              },
            ),
            ...CrashType.values.map((type) => ListTile(
              title: Text(type.name.toUpperCase()),
              selected: _selectedType == type,
              onTap: () {
                setState(() => _selectedType = type);
                Navigator.pop(context);
                _applyFilters();
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showSeverityFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Severity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Severities'),
              selected: _selectedSeverity == null,
              onTap: () {
                setState(() => _selectedSeverity = null);
                Navigator.pop(context);
                _applyFilters();
              },
            ),
            ...CrashSeverity.values.map((severity) => ListTile(
              title: Text(severity.name.toUpperCase()),
              selected: _selectedSeverity == severity,
              onTap: () {
                setState(() => _selectedSeverity = severity);
                Navigator.pop(context);
                _applyFilters();
              },
            )),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(CrashSeverity severity) {
    switch (severity) {
      case CrashSeverity.low:
        return Colors.blue;
      case CrashSeverity.medium:
        return Colors.orange;
      case CrashSeverity.high:
        return Colors.red;
      case CrashSeverity.critical:
        return Colors.red.shade800;
      case CrashSeverity.error:
        return Colors.red.shade600;
    }
  }

  Color _getBreadcrumbLevelColor(BreadcrumbLevel level) {
    switch (level) {
      case BreadcrumbLevel.debug:
        return Colors.grey;
      case BreadcrumbLevel.info:
        return Colors.blue;
      case BreadcrumbLevel.warning:
        return Colors.orange;
      case BreadcrumbLevel.error:
        return Colors.red;
      case BreadcrumbLevel.critical:
        return Colors.red.shade800;
    }
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
