import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'logger_data.dart';

class LogDetailScreen extends StatelessWidget {
  final LogEntry log;
  
  const LogDetailScreen({
    super.key,
    required this.log,
  });

  @override
  Widget build(BuildContext context) {
    final levelColor = Color(log.level.color);

    return Scaffold(
      appBar: AppBar(
        title: Text('${log.icon} ${log.level.name.toUpperCase()}'),
        backgroundColor: levelColor.withValues(alpha: 0.1),
        foregroundColor: levelColor,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'copy_message':
                  _copyToClipboard(context, log.message);
                  break;
                case 'copy_data':
                  _copyToClipboard(context, _formatJson(log.data));
                  break;
                case 'copy_stack':
                  if (log.stackTrace != null) {
                    _copyToClipboard(context, log.stackTrace!);
                  }
                  break;
                case 'copy_all':
                  _copyToClipboard(context, _generateFullReport());
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
              if (log.data.isNotEmpty)
                const PopupMenuItem(
                  value: 'copy_data',
                  child: ListTile(
                    leading: Icon(Icons.data_object),
                    title: Text('Copy Data'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              if (log.stackTrace != null)
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
                  title: Text('Copy Full Log'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Log Summary Card
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
                            color: levelColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: levelColor.withValues(alpha: 0.3)),
                          ),
                          child: Center(
                            child: Text(
                              log.icon,
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
                                log.level.name.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: levelColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _buildChip(log.tag, Colors.grey),
                                  const SizedBox(width: 8),
                                  _buildChip(
                                    'Priority: ${log.level.priority}',
                                    levelColor,
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
                    _buildInfoRow('Log ID', log.id),
                    _buildInfoRow('Timestamp', _formatDateTime(log.timestamp)),
                    _buildInfoRow('Tag', log.tag),
                    if (log.userId != null)
                      _buildInfoRow('User ID', log.userId!),
                    if (log.sessionId != null)
                      _buildInfoRow('Session ID', log.sessionId!),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Message Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Message',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () => _copyToClipboard(context, log.message),
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
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: SelectableText(
                        log.message,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Data Card
            if (log.data.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Data',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Text(
                            '${log.data.length} fields',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () => _copyToClipboard(context, _formatJson(log.data)),
                            icon: const Icon(Icons.copy, size: 16),
                            label: const Text('Copy'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade100,
                              foregroundColor: Colors.green.shade700,
                            ),
                          ),
                        ],
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
                          _formatJson(log.data),
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
            
            const SizedBox(height: 16),
            
            // Stack Trace Card
            if (log.stackTrace != null)
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
                            onPressed: () => _copyToClipboard(context, log.stackTrace!),
                            icon: const Icon(Icons.copy, size: 16),
                            label: const Text('Copy'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade100,
                              foregroundColor: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxHeight: 400),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SingleChildScrollView(
                          child: SelectableText(
                            log.stackTrace!,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Quick Actions Card
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
                          onPressed: () => _copyToClipboard(context, log.message),
                          icon: const Icon(Icons.message, size: 16),
                          label: const Text('Copy Message'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade100,
                            foregroundColor: Colors.blue.shade700,
                          ),
                        ),
                        
                        if (log.data.isNotEmpty)
                          ElevatedButton.icon(
                            onPressed: () => _copyToClipboard(context, _formatJson(log.data)),
                            icon: const Icon(Icons.data_object, size: 16),
                            label: const Text('Copy Data'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade100,
                              foregroundColor: Colors.green.shade700,
                            ),
                          ),
                        
                        ElevatedButton.icon(
                          onPressed: () => _copyToClipboard(context, _generateFullReport()),
                          icon: const Icon(Icons.copy_all, size: 16),
                          label: const Text('Copy Full Log'),
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
      ),
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

  void _copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatJson(Map<String, dynamic> data) {
    try {
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (e) {
      return data.toString();
    }
  }

  String _generateFullReport() {
    final buffer = StringBuffer();
    
    buffer.writeln('LOG ENTRY REPORT');
    buffer.writeln('=' * 50);
    buffer.writeln('ID: ${log.id}');
    buffer.writeln('Level: ${log.level.name.toUpperCase()}');
    buffer.writeln('Tag: ${log.tag}');
    buffer.writeln('Timestamp: ${_formatDateTime(log.timestamp)}');
    if (log.userId != null) {
      buffer.writeln('User ID: ${log.userId}');
    }
    if (log.sessionId != null) {
      buffer.writeln('Session ID: ${log.sessionId}');
    }
    buffer.writeln();
    
    buffer.writeln('MESSAGE:');
    buffer.writeln('-' * 20);
    buffer.writeln(log.message);
    buffer.writeln();
    
    if (log.data.isNotEmpty) {
      buffer.writeln('DATA:');
      buffer.writeln('-' * 20);
      buffer.writeln(_formatJson(log.data));
      buffer.writeln();
    }
    
    if (log.stackTrace != null) {
      buffer.writeln('STACK TRACE:');
      buffer.writeln('-' * 20);
      buffer.writeln(log.stackTrace);
    }
    
    return buffer.toString();
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}:'
           '${dateTime.second.toString().padLeft(2, '0')}.'
           '${dateTime.millisecond.toString().padLeft(3, '0')}';
  }
}
