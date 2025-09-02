import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'network_data.dart';

class NetworkDetailScreen extends StatefulWidget {
  final NetworkCall networkCall;
  
  const NetworkDetailScreen({
    super.key,
    required this.networkCall,
  });

  @override
  State<NetworkDetailScreen> createState() => _NetworkDetailScreenState();
}

class _NetworkDetailScreenState extends State<NetworkDetailScreen> with TickerProviderStateMixin {
  late TabController _tabController;

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
    final call = widget.networkCall;
    final statusColor = call.hasError ? Colors.red : 
                       call.isSuccess ? Colors.green : 
                       call.isCompleted ? Colors.orange : Colors.grey;

    return Scaffold(
      appBar: AppBar(
        title: Text(call.method),
        backgroundColor: statusColor.withValues(alpha: 0.1),
        foregroundColor: statusColor,
        bottom: TabBar(
          controller: _tabController,
          labelColor: statusColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: statusColor,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Request'),
            Tab(text: 'Response'),
            Tab(text: 'cURL'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _copyToClipboard(call.url),
            icon: const Icon(Icons.link),
            tooltip: 'Copy URL',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'copy_curl':
                  _copyToClipboard(call.curlCommand);
                  break;
                case 'copy_response':
                  _copyToClipboard(call.responseBody ?? '');
                  break;
                case 'copy_request':
                  _copyToClipboard(call.requestBody ?? '');
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'copy_curl',
                child: ListTile(
                  leading: Icon(Icons.code),
                  title: Text('Copy cURL'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'copy_request',
                child: ListTile(
                  leading: Icon(Icons.upload),
                  title: Text('Copy Request'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'copy_response',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Copy Response'),
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
          _buildOverviewTab(call),
          _buildRequestTab(call),
          _buildResponseTab(call),
          _buildCurlTab(call),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(NetworkCall call) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        call.isSuccess ? Icons.check_circle : 
                        call.hasError ? Icons.error : 
                        call.isCompleted ? Icons.warning : Icons.pending,
                        color: call.hasError ? Colors.red : 
                               call.isSuccess ? Colors.green : 
                               call.isCompleted ? Colors.orange : Colors.grey,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${call.method} ${call.statusCode ?? 'Pending'}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              call.statusText,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // URL
                  _buildInfoRow('URL', call.url, isSelectable: true),
                  
                  if (call.duration != null)
                    _buildInfoRow('Duration', '${call.duration}ms'),
                  
                  _buildInfoRow('Request Time', _formatDateTime(call.requestTime)),
                  
                  if (call.responseTime != null)
                    _buildInfoRow('Response Time', _formatDateTime(call.responseTime!)),
                  
                  if (call.requestSize != null)
                    _buildInfoRow('Request Size', _formatBytes(call.requestSize!)),
                  
                  if (call.responseSize != null)
                    _buildInfoRow('Response Size', _formatBytes(call.responseSize!)),
                  
                  if (call.error != null) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Error:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        call.error!,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
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
                        onPressed: () => _copyToClipboard(call.curlCommand),
                        icon: const Icon(Icons.code, size: 16),
                        label: const Text('Copy cURL'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade100,
                          foregroundColor: Colors.blue.shade700,
                        ),
                      ),
                      
                      ElevatedButton.icon(
                        onPressed: () => _copyToClipboard(call.url),
                        icon: const Icon(Icons.link, size: 16),
                        label: const Text('Copy URL'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade100,
                          foregroundColor: Colors.green.shade700,
                        ),
                      ),
                      
                      if (call.responseBody != null && call.responseBody!.isNotEmpty)
                        ElevatedButton.icon(
                          onPressed: () => _copyToClipboard(call.formattedResponseBody),
                          icon: const Icon(Icons.download, size: 16),
                          label: const Text('Copy Response'),
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

  Widget _buildRequestTab(NetworkCall call) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Request Headers
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Request Headers',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        '${call.requestHeaders.length} headers',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  if (call.requestHeaders.isEmpty)
                    const Text('No headers', style: TextStyle(color: Colors.grey))
                  else
                    ...call.requestHeaders.entries.map((entry) => 
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 120,
                              child: Text(
                                '${entry.key}:',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                            Expanded(
                              child: SelectableText(
                                entry.value,
                                style: const TextStyle(fontFamily: 'monospace'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Request Body
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Request Body',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      if (call.requestBody != null && call.requestBody!.isNotEmpty)
                        Text(
                          _formatBytes(call.requestBody!.length),
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  if (call.requestBody == null || call.requestBody!.isEmpty)
                    const Text('No request body', style: TextStyle(color: Colors.grey))
                  else
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxHeight: 400),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          call.formattedRequestBody,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseTab(NetworkCall call) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Response Headers
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Response Headers',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        '${call.responseHeaders?.length ?? 0} headers',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  if (call.responseHeaders == null || call.responseHeaders!.isEmpty)
                    const Text('No headers', style: TextStyle(color: Colors.grey))
                  else
                    ...call.responseHeaders!.entries.map((entry) => 
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 120,
                              child: Text(
                                '${entry.key}:',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                            Expanded(
                              child: SelectableText(
                                entry.value,
                                style: const TextStyle(fontFamily: 'monospace'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Response Body
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Response Body',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      if (call.responseBody != null && call.responseBody!.isNotEmpty)
                        Text(
                          _formatBytes(call.responseBody!.length),
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  if (call.responseBody == null || call.responseBody!.isEmpty)
                    const Text('No response body', style: TextStyle(color: Colors.grey))
                  else
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxHeight: 400),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          call.formattedResponseBody,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurlTab(NetworkCall call) {
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
                        'cURL Command',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () => _copyToClipboard(call.curlCommand),
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
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      call.curlCommand,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  const Text(
                    'How to use:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1. Copy the cURL command above\n'
                    '2. Open your terminal\n'
                    '3. Paste and run the command\n'
                    '4. You\'ll get the same response as your app',
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

  Widget _buildInfoRow(String label, String value, {bool isSelectable = false}) {
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
            child: isSelectable 
              ? SelectableText(
                  value,
                  style: const TextStyle(fontFamily: 'monospace'),
                )
              : Text(
                  value,
                  style: TextStyle(
                    fontFamily: isSelectable ? 'monospace' : null,
                    color: Colors.grey.shade700,
                  ),
                ),
          ),
        ],
      ),
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}:'
           '${dateTime.second.toString().padLeft(2, '0')}';
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}
