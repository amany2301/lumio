import 'package:flutter/material.dart';

/// Base interface for all Lumio plugins
/// Similar to Android Pluto's plugin architecture
abstract class Plugin {
  /// Plugin name
  String get name;
  
  /// Plugin description
  String get description;
  
  /// Plugin version
  String get version => '1.0.0';
  
  /// Plugin icon (optional)
  IconData? get icon;
  
  /// Plugin color theme (optional)
  Color? get color;
  
  /// Whether the plugin is enabled
  bool get isEnabled => true;
  
  /// Initialize the plugin
  void initialize();
  
  /// Dispose the plugin
  void dispose();
  
  /// Build the debug screen for this plugin
  Widget buildDebugScreen();
  
  /// Get plugin configuration
  PluginConfiguration? get configuration => null;
  
  /// Get plugin statistics
  PluginStatistics get statistics => PluginStatistics();
  
  /// Export plugin data
  Future<Map<String, dynamic>> exportData() async {
    return {
      'name': name,
      'description': description,
      'version': version,
      'enabled': isEnabled,
      'statistics': statistics.toJson(),
    };
  }
}

/// Plugin configuration
class PluginConfiguration {
  final bool enableNotifications;
  final bool enableExport;
  final int maxStoredItems;
  final Duration dataRetentionPeriod;
  
  const PluginConfiguration({
    this.enableNotifications = true,
    this.enableExport = true,
    this.maxStoredItems = 1000,
    this.dataRetentionPeriod = const Duration(days: 7),
  });
  
  Map<String, dynamic> toJson() {
    return {
      'enableNotifications': enableNotifications,
      'enableExport': enableExport,
      'maxStoredItems': maxStoredItems,
      'dataRetentionPeriod': dataRetentionPeriod.inDays,
    };
  }
}

/// Plugin statistics
class PluginStatistics {
  final int totalItems;
  final int errorCount;
  final int warningCount;
  final DateTime lastActivity;
  final Duration uptime;
  
  const PluginStatistics({
    this.totalItems = 0,
    this.errorCount = 0,
    this.warningCount = 0,
    DateTime? lastActivity,
    this.uptime = Duration.zero,
  }) : lastActivity = lastActivity ?? DateTime.now();
  
  Map<String, dynamic> toJson() {
    return {
      'totalItems': totalItems,
      'errorCount': errorCount,
      'warningCount': warningCount,
      'lastActivity': lastActivity.toIso8601String(),
      'uptime': uptime.inSeconds,
    };
  }
}

/// Plugin group for organizing related plugins
abstract class PluginGroup {
  /// Group identifier
  String get id;
  
  /// Group name
  String get name;
  
  /// Group description
  String get description;
  
  /// Group icon
  IconData? get icon;
  
  /// Group color
  Color? get color;
  
  /// Plugins in this group
  List<Plugin> get plugins;
  
  /// Group configuration
  PluginGroupConfiguration? get configuration => null;
}

/// Plugin group configuration
class PluginGroupConfiguration {
  final bool collapsible;
  final bool expandedByDefault;
  final String? category;
  
  const PluginGroupConfiguration({
    this.collapsible = true,
    this.expandedByDefault = true,
    this.category,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'collapsible': collapsible,
      'expandedByDefault': expandedByDefault,
      'category': category,
    };
  }
}

/// Core plugin bundle (similar to Pluto's bundle-core)
class CorePluginBundle extends PluginGroup {
  @override
  String get id => 'core-bundle';
  
  @override
  String get name => 'Core Bundle';
  
  @override
  String get description => 'Essential debugging plugins for network, crashes, and logging';
  
  @override
  IconData? get icon => Icons.bug_report;
  
  @override
  Color? get color => Colors.blue;
  
  @override
  List<Plugin> get plugins => [
    NetworkPlugin(),
    CrashPlugin(),
    LoggerPlugin(),
  ];
  
  @override
  PluginGroupConfiguration get configuration => const PluginGroupConfiguration(
    collapsible: false,
    expandedByDefault: true,
    category: 'core',
  );
}

/// Plugin registry for managing all plugins
class PluginRegistry {
  static final PluginRegistry _instance = PluginRegistry._internal();
  factory PluginRegistry() => _instance;
  PluginRegistry._internal();
  
  final Map<String, Plugin> _plugins = {};
  final Map<String, PluginGroup> _groups = {};
  
  /// Register a plugin
  void registerPlugin(Plugin plugin) {
    _plugins[plugin.name] = plugin;
  }
  
  /// Register a plugin group
  void registerGroup(PluginGroup group) {
    _groups[group.id] = group;
    for (final plugin in group.plugins) {
      registerPlugin(plugin);
    }
  }
  
  /// Get all plugins
  List<Plugin> get allPlugins => _plugins.values.toList();
  
  /// Get all groups
  List<PluginGroup> get allGroups => _groups.values.toList();
  
  /// Get plugin by name
  Plugin? getPlugin(String name) => _plugins[name];
  
  /// Get group by id
  PluginGroup? getGroup(String id) => _groups[id];
  
  /// Get enabled plugins
  List<Plugin> get enabledPlugins => _plugins.values.where((p) => p.isEnabled).toList();
  
  /// Clear all plugins
  void clear() {
    _plugins.clear();
    _groups.clear();
  }
  
  /// Export all plugin data
  Future<Map<String, dynamic>> exportAllData() async {
    final data = <String, dynamic>{
      'plugins': {},
      'groups': {},
    };
    
    for (final plugin in _plugins.values) {
      data['plugins'][plugin.name] = await plugin.exportData();
    }
    
    for (final group in _groups.values) {
      data['groups'][group.id] = {
        'name': group.name,
        'description': group.description,
        'plugins': group.plugins.map((p) => p.name).toList(),
        'configuration': group.configuration?.toJson(),
      };
    }
    
    return data;
  }
}
