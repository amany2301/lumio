import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/lumio_logger.dart';

/// Lumio debug overlay widget that provides on-device debugging UI
class LumioDebugOverlay extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const LumioDebugOverlay({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  State<LumioDebugOverlay> createState() => _LumioDebugOverlayState();
}

class _LumioDebugOverlayState extends State<LumioDebugOverlay> {
  bool _isVisible = false;
  bool _isExpanded = false;
  int _httpRequestCount = 0;
  int _crashCount = 0;
  int _anrCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  void _loadCounts() {
    // TODO: Load actual counts from storage
    _httpRequestCount = 0;
    _crashCount = 0;
    _anrCount = 0;
  }

  void _toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _clearLogs() {
    setState(() {
      _httpRequestCount = 0;
      _crashCount = 0;
      _anrCount = 0;
    });
    LumioLogger.info('All debugging data cleared');
  }

  void _shareLogs() {
    // TODO: Implement log sharing functionality
    LumioLogger.info('Sharing debugging logs...');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Log sharing feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        if (_isVisible)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 10,
            child: _buildDebugPanel(),
          ),
        Positioned(
          bottom: 20,
          right: 20,
          child: _buildToggleButton(),
        ),
      ],
    );
  }

  Widget _buildToggleButton() {
    return FloatingActionButton(
      onPressed: _toggleVisibility,
      backgroundColor: Colors.blue,
      child: Icon(
        _isVisible ? Icons.visibility_off : Icons.visibility,
        color: Colors.white,
      ),
    );
  }

  Widget _buildDebugPanel() {
    return Container(
      width: _isExpanded ? 300 : 200,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          if (_isExpanded) _buildExpandedContent(),
          _buildCollapsedContent(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.bug_report, color: Colors.blue, size: 16),
          const SizedBox(width: 4),
          const Text(
            'Lumio Debug',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _toggleExpanded,
            icon: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.blue,
              size: 16,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
          ),
          IconButton(
            onPressed: _toggleVisibility,
            icon: const Icon(Icons.close, color: Colors.blue, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedContent() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetric('HTTP', _httpRequestCount, Colors.green),
          _buildMetric('Crash', _crashCount, Colors.red),
          _buildMetric('ANR', _anrCount, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetricRow('HTTP Requests', _httpRequestCount, Colors.green),
          _buildMetricRow('Crashes', _crashCount, Colors.red),
          _buildMetricRow('ANRs', _anrCount, Colors.orange),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _clearLogs,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                  ),
                  child: const Text('Clear', style: TextStyle(fontSize: 10)),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: ElevatedButton(
                  onPressed: _shareLogs,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                  ),
                  child: const Text('Share', style: TextStyle(fontSize: 10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// LumioApp widget that wraps your app with debugging capabilities
class LumioApp extends StatelessWidget {
  final Widget child;
  final bool enableDebugOverlay;

  const LumioApp({
    super.key,
    required this.child,
    this.enableDebugOverlay = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enableDebugOverlay) {
      return child;
    }

    return LumioDebugOverlay(
      enabled: enableDebugOverlay,
      child: child,
    );
  }
}
