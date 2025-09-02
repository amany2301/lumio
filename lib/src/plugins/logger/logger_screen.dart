import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'logger_manager.dart';
import 'logger_data.dart';
import 'log_detail_screen.dart';

class LoggerScreen extends StatefulWidget {
  const LoggerScreen({super.key});

  @override
  State<LoggerScreen> createState() => _LoggerScreenState();
}

class _LoggerScreenState extends State<LoggerScreen> with TickerProviderStateMixin {
  final LoggerManager _loggerManager = LoggerManager();
  final TextEditingController _searchController = TextEditingController();
  
  List<LogEntry> _filteredLogs = [];
  LogLevel? _selectedLevel;
  String? _selectedTag;
  bool _autoScroll = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _filteredLogs = _loggerManager.allLogs;
    
    // Listen to new logs
    _loggerManager.logStream.listen((_) {
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
      var logs = _loggerManager.allLogs;
      
      // Apply search filter
      if (_searchController.text.isNotEmpty) {
        logs = _loggerManager.searchLogs(_searchController.text);
      }
      
      // Apply level filter
      if (_selectedLevel != null) {
        logs = logs.where((log) => log.level == _selectedLevel).toList();
      }
      
      // Apply tag filter
      if (_selectedTag != null) {
        logs = logs.where((log) => log.tag == _selectedTag).toList();
      }
      
      _filteredLogs = logs;
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedLevel = null;
      _selectedTag = null;
      _filteredLogs = _loggerManager.allLogs;
    });
  }

  void _exportData() async {
    final data = _loggerManager.exportAsJson();
    final jsonString = data.toString();
    
    await Clipboard.setData(ClipboardData(text: jsonString));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Log data exported to clipboard!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _addTestLogs() {
    final tags = ['UI', 'Network', 'Database', 'Auth', 'Analytics'];
    final levels = LogLevel.values;
    final messages = [
      'User interaction detected',
      'API request completed successfully',
      'Database query executed',
      'User authentication failed',
      'Screen navigation occurred',
      'Cache updated',
      'Background task started',
      'Error parsing response',
      'Memory warning received',
      'Feature flag evaluated',
    ];

    for (int i = 0; i < 10; i++) {
      final level = levels[i % levels.length];
      final tag = tags[i % tags.length];
      final message = messages[i % messages.length];
      
      _loggerManager.log(
        level: level,
        tag: tag,
        message: '$message (test log ${i + 1})',
        data: {
          'testId': i + 1,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'random': (i * 123) % 1000,
        },
        stackTrace: level == LogLevel.error || level == LogLevel.fatal 
          ? 'Stack trace for $message\n  at TestClass.testMethod(test.dart:${10 + i})\n  at main(main.dart:${20 + i})'
          : null,
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Added 10 test logs!'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logger Monitor'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Logs', icon: Icon(Icons.list_alt)),
            Tab(text: 'Statistics', icon: Icon(Icons.analytics)),
            Tab(text: 'Settings', icon: Icon(Icons.settings)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _addTestLogs,
            icon: const Icon(Icons.add),
            tooltip: 'Add Test Logs',
          ),
          IconButton(
            onPressed: _exportData,
            icon: const Icon(Icons.download),
            tooltip: 'Export Data',
          ),
          IconButton(
            onPressed: () {
              _loggerManager.clearAll();
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
          _buildLogsTab(),
          _buildStatisticsTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  Widget _buildLogsTab() {
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
                  hintText: 'Search logs, tags, messages...',
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
              
              // Filter Chips Row 1
              Row(
                children: [
                  // Level Filter
                  Expanded(
                    child: FilterChip(
                      label: Text(_selectedLevel?.name.toUpperCase() ?? 'All Levels'),
                      selected: _selectedLevel != null,
                      onSelected: (selected) {
                        _showLevelFilter();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Tag Filter
                  Expanded(
                    child: FilterChip(
                      label: Text(_selectedTag ?? 'All Tags'),
                      selected: _selectedTag != null,
                      onSelected: (selected) {
                        _showTagFilter();
                      },
                    ),
                  ),
                ],
              ),
              
              // Filter Chips Row 2
              Row(
                children: [
                  // Auto-scroll toggle
                  FilterChip(
                    label: Text('Auto-scroll: ${_autoScroll ? 'ON' : 'OFF'}'),
                    selected: _autoScroll,
                    onSelected: (selected) {
                      setState(() => _autoScroll = selected);
                    },
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Clear Filters
                  if (_selectedLevel != null || _selectedTag != null || _searchController.text.isNotEmpty)
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
        
        // Logs List
        Expanded(
          child: _filteredLogs.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.list_alt, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No logs found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Logs will appear here as they are generated',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                reverse: _autoScroll,
                itemCount: _filteredLogs.length,
                itemBuilder: (context, index) {
                  final log = _filteredLogs[index];
                  return _buildLogTile(log);
                },
              ),
        ),
      ],
    );
  }

  Widget _buildStatisticsTab() {
    return StreamBuilder<LogStats>(
      stream: _loggerManager.statsStream,
      initialData: _loggerManager.stats,
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
                  Expanded(child: _buildStatCard('Total Logs', stats.totalLogs.toString(), Colors.blue)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildStatCard('Error Rate', '${stats.errorRate.toStringAsFixed(1)}%', Colors.red)),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Expanded(child: _buildStatCard('Most Active', stats.mostActiveTag, Colors.green)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildStatCard('Errors', '${stats.errorLogs + stats.fatalLogs}', Colors.orange)),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Log Levels Breakdown
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Log Levels Breakdown',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildStatRow('Verbose', '${stats.verboseLogs}', Color(LogLevel.verbose.color)),
                      _buildStatRow('Debug', '${stats.debugLogs}', Color(LogLevel.debug.color)),
                      _buildStatRow('Info', '${stats.infoLogs}', Color(LogLevel.info.color)),
                      _buildStatRow('Warning', '${stats.warningLogs}', Color(LogLevel.warning.color)),
                      _buildStatRow('Error', '${stats.errorLogs}', Color(LogLevel.error.color)),
                      _buildStatRow('Fatal', '${stats.fatalLogs}', Color(LogLevel.fatal.color)),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Top Tags
              if (stats.tagBreakdown.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Top Tags',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        
                        ...(stats.tagBreakdown.entries
                          .toList()
                          ..sort((a, b) => b.value.compareTo(a.value))
                          ..take(10))
                          .map((entry) => _buildStatRow(entry.key, '${entry.value}', Colors.grey)),
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
                        'Session Information',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildInfoRow('Session ID', _loggerManager.currentSessionId ?? 'N/A'),
                      _buildInfoRow('User ID', _loggerManager.currentUserId ?? 'N/A'),
                      if (stats.firstLogTime != null)
                        _buildInfoRow('First Log', _formatDateTime(stats.firstLogTime!)),
                      if (stats.lastLogTime != null)
                        _buildInfoRow('Last Log', _formatDateTime(stats.lastLogTime!)),
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

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logger Controls
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Logger Controls',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // Clear options
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _loggerManager.clearAll(),
                        icon: const Icon(Icons.clear_all, size: 16),
                        label: const Text('Clear All Logs'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade100,
                          foregroundColor: Colors.red.shade700,
                        ),
                      ),
                      
                      ElevatedButton.icon(
                        onPressed: () => _loggerManager.clearOldLogs(const Duration(hours: 1)),
                        icon: const Icon(Icons.schedule, size: 16),
                        label: const Text('Clear Old (1h+)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade100,
                          foregroundColor: Colors.orange.shade700,
                        ),
                      ),
                      
                      ElevatedButton.icon(
                        onPressed: () => _loggerManager.clearLogsByLevel(LogLevel.verbose),
                        icon: const Icon(Icons.filter_list, size: 16),
                        label: const Text('Clear Verbose'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          foregroundColor: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Session Management
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Session Management',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildInfoRow('Current Session', _loggerManager.currentSessionId ?? 'N/A'),
                  _buildInfoRow('Current User', _loggerManager.currentUserId ?? 'N/A'),
                  
                  const SizedBox(height: 12),
                  
                  ElevatedButton.icon(
                    onPressed: () => _loggerManager.startNewSession(),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Start New Session'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade100,
                      foregroundColor: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Quick Actions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _addTestLogs,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Test Logs'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade100,
                          foregroundColor: Colors.green.shade700,
                        ),
                      ),
                      
                      ElevatedButton.icon(
                        onPressed: _exportData,
                        icon: const Icon(Icons.download, size: 16),
                        label: const Text('Export Data'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade100,
                          foregroundColor: Colors.purple.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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

  Widget _buildLogTile(LogEntry log) {
    final levelColor = Color(log.level.color);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: levelColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: levelColor.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text(
              log.icon,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        title: Text(
          log.message,
          style: const TextStyle(fontSize: 13),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: levelColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    log.level.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: levelColor,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    log.tag,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _formatTime(log.timestamp),
                  style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.grey.shade400,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LogDetailScreen(log: log),
            ),
          );
        },
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }

  void _showLevelFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Level'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Levels'),
              selected: _selectedLevel == null,
              onTap: () {
                setState(() => _selectedLevel = null);
                Navigator.pop(context);
                _applyFilters();
              },
            ),
            ...LogLevel.values.map((level) => ListTile(
              leading: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Color(level.color),
                  shape: BoxShape.circle,
                ),
              ),
              title: Text(level.name.toUpperCase()),
              selected: _selectedLevel == level,
              onTap: () {
                setState(() => _selectedLevel = level);
                Navigator.pop(context);
                _applyFilters();
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showTagFilter() {
    final tags = _loggerManager.getUniqueTags();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Tag'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('All Tags'),
                selected: _selectedTag == null,
                onTap: () {
                  setState(() => _selectedTag = null);
                  Navigator.pop(context);
                  _applyFilters();
                },
              ),
              if (tags.isNotEmpty) ...[
                const Divider(),
                SizedBox(
                  height: 200,
                  child: ListView(
                    children: tags.map((tag) => ListTile(
                      title: Text(tag),
                      selected: _selectedTag == tag,
                      onTap: () {
                        setState(() => _selectedTag = tag);
                        Navigator.pop(context);
                        _applyFilters();
                      },
                    )).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
