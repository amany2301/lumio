import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'crash_data.dart';
import 'crash_manager.dart';

class CrashDetailScreen extends StatefulWidget {
  final CrashReport crash;
  
  const CrashDetailScreen({
    super.key,
    required this.crash,
  });

  @override
  State<CrashDetailScreen> createState() => _CrashDetailScreenState();
}

class _CrashDetailScreenState extends State<CrashDetailScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final CrashManager _crashManager = CrashManager();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final crash = widget.crash;
    final severityColor = _getSeverityColor(crash.severity);

    return Scaffold(
      appBar: AppBar(
        title: Text('${crash.icon} ${crash.title}'),
        backgroundColor: severityColor.withValues(alpha: 0.1),
        foregroundColor: severityColor,
        bottom: TabBar(
          controller: _tabController,
          labelColor: severityColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: severityColor,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Stack Trace'),
            Tab(text: 'Context'),
            Tab(text: 'Breadcrumbs'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'copy_message':
                  _copyToClipboard(crash.message);
                  break;
                case 'copy_stack':
                  _copyToClipboard(crash.stackTrace);
                  break;
                case 'copy_all':
                  _copyToClipboard(_generateFullReport());
                  break;
                case 'share':
                  _shareReport();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'copy_message',
                child: ListTile(
                  leading: Icon(Icons.message),
                  title: Text('Copy Message'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'copy_stack',
                child: ListTile(
                  leading: Icon(Icons.code),
                  title: Text('Copy Stack Trace'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'copy_all',
                child: ListTile(
                  leading: Icon(Icons.copy_all),
                  title: Text('Copy Full Report'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Share Report'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(crash),
          _buildStackTraceTab(crash),
          _buildContextTab(crash),
          _buildBreadcrumbsTab(crash),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(CrashReport crash) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Crash Summary Card
          Card(
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
                          color: _getSeverityColor(crash.severity).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getSeverityColor(crash.severity).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            crash.icon,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              crash.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _buildChip(
                                  crash.type.name.toUpperCase(),
                                  _getTypeColor(crash.type),
                                ),
                                const SizedBox(width: 8),
                                _buildChip(
                                  crash.severity.name.toUpperCase(),
                                  _getSeverityColor(crash.severity),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Basic Info
                  _buildInfoRow('Timestamp', _formatDateTime(crash.timestamp)),
                  _buildInfoRow('Crash ID', crash.id),
                  if (crash.userId != null)
                    _buildInfoRow('User ID', crash.userId!),
                  
                  const SizedBox(height: 16),
                  
                  // Message
                  const Text(
                    'Message:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: SelectableText(
                      crash.message,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Device Info Card
          if (crash.deviceInfo.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Device Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    
                    ...crash.deviceInfo.entries.map((entry) =>
                      _buildInfoRow(entry.key, entry.value),
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
                  const SizedBox(height: 12),
                  
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _copyToClipboard(crash.message),
                        icon: const Icon(Icons.message, size: 16),
                        label: const Text('Copy Message'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade100,
                          foregroundColor: Colors.blue.shade700,
                        ),
                      ),
                      
                      ElevatedButton.icon(
                        onPressed: () => _copyToClipboard(crash.stackTrace),
                        icon: const Icon(Icons.code, size: 16),
                        label: const Text('Copy Stack Trace'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade100,
                          foregroundColor: Colors.green.shade700,
                        ),
                      ),
                      
                      ElevatedButton.icon(
                        onPressed: () => _copyToClipboard(_generateFullReport()),
                        icon: const Icon(Icons.copy_all, size: 16),
                        label: const Text('Copy Full Report'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade100,
                          foregroundColor: Colors.orange.shade700,
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

  Widget _buildStackTraceTab(CrashReport crash) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Stack Trace',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () => _copyToClipboard(crash.stackTrace),
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Copy'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade100,
                          foregroundColor: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 600),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        crash.formattedStackTrace,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  const Text(
                    'How to read stack traces:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Each line represents a function call in the call stack\n'
                    '• The top line is where the error occurred\n'
                    '• Lines below show the sequence of function calls that led to the error\n'
                    '• File paths and line numbers help locate the exact code',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextTab(CrashReport crash) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Context Data
          if (crash.context.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Context Data',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    
                    ...crash.context.entries.map((entry) =>
                      _buildInfoRow(entry.key, entry.value.toString()),
                    ),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Custom Data
          if (crash.customData.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Custom Data',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: SelectableText(
                        _formatJson(crash.customData),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // If no context or custom data
          if (crash.context.isEmpty && crash.customData.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.info_outline, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No additional context data',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbsTab(CrashReport crash) {
    final breadcrumbs = _crashManager.getBreadcrumbsForCrash(crash);
    
    return breadcrumbs.isEmpty
      ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timeline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No breadcrumbs found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Breadcrumbs show user actions leading up to this crash',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )
      : Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Showing ${breadcrumbs.length} breadcrumbs from 10 minutes before the crash',
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: breadcrumbs.length,
                itemBuilder: (context, index) {
                  final breadcrumb = breadcrumbs[index];
                  return _buildBreadcrumbTile(breadcrumb);
                },
              ),
            ),
          ],
        );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
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
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbTile(CrashBreadcrumb breadcrumb) {
    final levelColor = _getBreadcrumbLevelColor(breadcrumb.level);

    return ListTile(
      leading: Container(
        width: 12,
        height: 12,
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

  void _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _shareReport() {
    // In a real app, you would use share_plus package or similar
    _copyToClipboard(_generateFullReport());
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Full report copied to clipboard for sharing!'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  String _generateFullReport() {
    final crash = widget.crash;
    final buffer = StringBuffer();
    
    buffer.writeln('CRASH REPORT');
    buffer.writeln('=' * 50);
    buffer.writeln('Title: ${crash.title}');
    buffer.writeln('Type: ${crash.type.name.toUpperCase()}');
    buffer.writeln('Severity: ${crash.severity.name.toUpperCase()}');
    buffer.writeln('Timestamp: ${_formatDateTime(crash.timestamp)}');
    buffer.writeln('Crash ID: ${crash.id}');
    if (crash.userId != null) {
      buffer.writeln('User ID: ${crash.userId}');
    }
    buffer.writeln();
    
    buffer.writeln('MESSAGE:');
    buffer.writeln('-' * 20);
    buffer.writeln(crash.message);
    buffer.writeln();
    
    buffer.writeln('STACK TRACE:');
    buffer.writeln('-' * 20);
    buffer.writeln(crash.stackTrace);
    buffer.writeln();
    
    if (crash.deviceInfo.isNotEmpty) {
      buffer.writeln('DEVICE INFO:');
      buffer.writeln('-' * 20);
      crash.deviceInfo.forEach((key, value) {
        buffer.writeln('$key: $value');
      });
      buffer.writeln();
    }
    
    if (crash.context.isNotEmpty) {
      buffer.writeln('CONTEXT:');
      buffer.writeln('-' * 20);
      buffer.writeln(_formatJson(crash.context));
      buffer.writeln();
    }
    
    if (crash.customData.isNotEmpty) {
      buffer.writeln('CUSTOM DATA:');
      buffer.writeln('-' * 20);
      buffer.writeln(_formatJson(crash.customData));
    }
    
    return buffer.toString();
  }

  String _formatJson(Map<String, dynamic> data) {
    try {
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (e) {
      return data.toString();
    }
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

  Color _getTypeColor(CrashType type) {
    switch (type) {
      case CrashType.flutter:
        return Colors.blue;
      case CrashType.native:
        return Colors.orange;
      case CrashType.anr:
        return Colors.red;
      case CrashType.network:
        return Colors.purple;
      case CrashType.memory:
        return Colors.brown;
      case CrashType.custom:
        return Colors.grey;
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
           '${dateTime.minute.toString().padLeft(2, '0')}:'
           '${dateTime.second.toString().padLeft(2, '0')}';
  }
}
