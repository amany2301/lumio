import 'package:flutter/material.dart';
import 'lumio_debug_screen.dart';
import '../plugins/network/network_screen.dart';
import '../plugins/crashes/crash_screen.dart';
import '../plugins/logger/logger_screen.dart';

/// A floating debug button overlay that can be added to any screen
class LumioDebugOverlay extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final Alignment alignment;
  final EdgeInsets margin;

  const LumioDebugOverlay({
    super.key,
    required this.child,
    this.enabled = true,
    this.alignment = Alignment.bottomRight,
    this.margin = const EdgeInsets.all(16.0),
  });

  @override
  State<LumioDebugOverlay> createState() => _LumioDebugOverlayState();
}

class _LumioDebugOverlayState extends State<LumioDebugOverlay>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.125, // 45 degrees (1/8 of a full rotation)
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _openDebugConsole() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LumioDebugScreen(),
      ),
    );
    
    // Collapse after opening
    if (_isExpanded) {
      _toggleExpanded();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        
        // Debug Overlay
        Positioned.fill(
          child: Align(
            alignment: widget.alignment,
            child: Container(
              margin: widget.margin,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Quick Action Buttons (when expanded)
                  AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_scaleAnimation.value > 0) ...[
                              _buildQuickActionButton(
                                icon: Icons.network_check,
                                label: 'Network',
                                color: Colors.blue,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const NetworkScreen(),
                                    ),
                                  );
                                  _toggleExpanded();
                                },
                              ),
                              
                              const SizedBox(height: 8),
                              
                              _buildQuickActionButton(
                                icon: Icons.bug_report,
                                label: 'Crashes',
                                color: Colors.red,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const CrashScreen(),
                                    ),
                                  );
                                  _toggleExpanded();
                                },
                              ),
                              
                              const SizedBox(height: 8),
                              
                              _buildQuickActionButton(
                                icon: Icons.list_alt,
                                label: 'Logs',
                                color: Colors.purple,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoggerScreen(),
                                    ),
                                  );
                                  _toggleExpanded();
                                },
                              ),
                              
                              const SizedBox(height: 12),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                  
                  // Main Debug Button
                  GestureDetector(
                    onTap: _toggleExpanded,
                    onLongPress: _openDebugConsole,
                    child: AnimatedBuilder(
                      animation: _rotationAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationAnimation.value * 2 * 3.14159,
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.indigo,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.developer_mode,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Convenience method to wrap your app with Lumio debug overlay
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
    return LumioDebugOverlay(
      enabled: enableDebugOverlay,
      child: child,
    );
  }
}
