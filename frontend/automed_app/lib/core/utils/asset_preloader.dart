import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Dynamic Asset Preloading System for Automed
/// Automatically discovers, categorizes, and preloads assets based on usage patterns

class AssetPreloader {
  static final Map<String, PreloadedAsset> _preloadedAssets = {};
  static final Map<String, DynamicAssetBundle> _dynamicBundles = {};
  static final Map<String, AssetUsagePattern> _usagePatterns = {};
  static final Map<String, AssetCategory> _assetCategories = {};
  static final Set<String> _allDiscoveredAssets = {};
  static final List<String> _criticalAssets = [];
  static final List<String> _frequentAssets = [];
  static bool _isInitialized = false;

  // Navigation prediction
  static final List<String> _navigationHistory = [];
  static final Map<String, Map<String, double>> _transitionProbabilities = {};

  /// Initialize the dynamic asset preloader
  static Future<void> initialize(BuildContext context) async {
    if (_isInitialized) return;

    try {
      debugPrint('🚀 Initializing dynamic asset preloader...');

      // Step 1: Discover all assets dynamically
      await _discoverAllAssets();

      // Step 2: Categorize assets by type and usage
      await _categorizeAssets();

      // Step 3: Identify critical and frequent assets
      await _identifyCriticalAndFrequentAssets();

      // Step 4: Preload critical assets with priority
      await _preloadCriticalAssets(context);

      // Step 5: Start background preloading of frequent assets
      unawaited(_startBackgroundPreloading(context));

      // Step 6: Initialize usage pattern tracking
      _initializeUsageTracking();

      _isInitialized = true;
      debugPrint('✅ Dynamic asset preloader initialized successfully');
      debugPrint('📊 Discovered ${_allDiscoveredAssets.length} assets');
      debugPrint('🎯 Critical assets: ${_criticalAssets.length}');
      debugPrint('🔄 Frequent assets: ${_frequentAssets.length}');
    } catch (e) {
      debugPrint('❌ Failed to initialize asset preloader: $e');
    }
  }

  /// Dynamically discover all assets from the manifest
  static Future<void> _discoverAllAssets() async {
    try {
      debugPrint('🔍 Discovering all assets from manifest...');

      // Load asset manifest
      final manifestJson = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifest = json.decode(manifestJson);

      // Extract all asset paths
      for (final assetPath in manifest.keys) {
        _allDiscoveredAssets.add(assetPath);
      }

      debugPrint('📋 Found ${_allDiscoveredAssets.length} total assets');
    } catch (e) {
      debugPrint('❌ Failed to discover assets: $e');
    }
  }

  /// Categorize assets by type and potential usage
  static Future<void> _categorizeAssets() async {
    debugPrint('🏷️ Categorizing assets...');

    for (final assetPath in _allDiscoveredAssets) {
      final category = _determineAssetCategory(assetPath);
      _assetCategories[assetPath] = category;

      // Initialize usage pattern
      _usagePatterns[assetPath] = AssetUsagePattern(
        assetPath: assetPath,
        category: category,
        accessCount: 0,
        lastAccessed: null,
        predictedNextAccess: null,
      );
    }

    debugPrint('✅ Categorized ${_assetCategories.length} assets');
  }

  /// Determine asset category based on path and naming patterns
  static AssetCategory _determineAssetCategory(String assetPath) {
    // Critical system assets
    if (assetPath.contains('splash') ||
        assetPath.contains('icon') ||
        assetPath.contains('logo')) {
      return AssetCategory.critical;
    }

    // UI assets
    if (assetPath.contains('button') ||
        assetPath.contains('card') ||
        assetPath.contains('dialog')) {
      return AssetCategory.ui;
    }

    // Feature-specific assets
    if (assetPath.contains('patient') || assetPath.contains('dashboard')) {
      return AssetCategory.patient;
    }
    if (assetPath.contains('hospital') ||
        assetPath.contains('staff') ||
        assetPath.contains('equipment')) {
      return AssetCategory.hospital;
    }
    if (assetPath.contains('consultation') ||
        assetPath.contains('video') ||
        assetPath.contains('chat')) {
      return AssetCategory.consultation;
    }
    if (assetPath.contains('medication') ||
        assetPath.contains('pill') ||
        assetPath.contains('reminder')) {
      return AssetCategory.medication;
    }
    if (assetPath.contains('emergency') || assetPath.contains('alert')) {
      return AssetCategory.emergency;
    }
    if (assetPath.contains('ai') || assetPath.contains('assistant')) {
      return AssetCategory.ai;
    }

    // Default category
    return AssetCategory.common;
  }

  /// Identify critical and frequently used assets
  static Future<void> _identifyCriticalAndFrequentAssets() async {
    debugPrint('🎯 Identifying critical and frequent assets...');

    // Critical assets are those needed immediately on app start
    _criticalAssets.addAll(_assetCategories.entries
        .where((entry) => entry.value == AssetCategory.critical)
        .map((entry) => entry.key));

    // Frequent assets are common UI elements and placeholders
    _frequentAssets.addAll(_assetCategories.entries
            .where((entry) => [
                  AssetCategory.ui,
                  AssetCategory.common,
                  AssetCategory.patient,
                ].contains(entry.value))
            .map((entry) => entry.key)
            .take(20) // Limit to top 20 frequent assets
        );

    debugPrint(
        '🎯 Critical: ${_criticalAssets.length}, Frequent: ${_frequentAssets.length}');
  }

  /// Preload critical assets with high priority
  static Future<void> _preloadCriticalAssets(BuildContext context) async {
    if (_criticalAssets.isEmpty) return;

    debugPrint('⚡ Preloading critical assets...');

    await Future.wait(
      _criticalAssets
          .map((asset) => _preloadAsset(context, asset, priority: 10)),
    );

    debugPrint('✅ Critical assets preloaded');
  }

  /// Start background preloading of frequent assets
  static Future<void> _startBackgroundPreloading(BuildContext context) async {
    if (_frequentAssets.isEmpty) return;

    debugPrint('🔄 Starting background preloading...');

    // Preload in batches to avoid blocking UI
    const batchSize = 5;
    for (var i = 0; i < _frequentAssets.length; i += batchSize) {
      final batch = _frequentAssets.skip(i).take(batchSize);
      unawaited(Future.wait(
        batch.map((asset) => _preloadAsset(context, asset, priority: 5)),
      ));

      // Small delay between batches
      await Future.delayed(const Duration(milliseconds: 100));
    }

    debugPrint('✅ Background preloading completed');
  }

  /// Initialize usage pattern tracking
  static void _initializeUsageTracking() {
    debugPrint('📊 Usage tracking initialized');
  }

  /// Preload a single asset with priority
  static Future<void> _preloadAsset(BuildContext context, String assetPath,
      {int priority = 1}) async {
    if (_preloadedAssets.containsKey(assetPath)) return;

    try {
      final image = AssetImage(assetPath);
      await precacheImage(image, context);

      _preloadedAssets[assetPath] = PreloadedAsset(
        assetPath: assetPath,
        type: _getAssetType(assetPath),
        loadedAt: DateTime.now(),
        priority: priority,
      );

      // Update usage pattern
      final pattern = _usagePatterns[assetPath];
      if (pattern != null) {
        pattern.accessCount++;
        pattern.lastAccessed = DateTime.now();
      }

      debugPrint('✅ Preloaded: $assetPath (priority: $priority)');
    } catch (e) {
      debugPrint('❌ Failed to preload $assetPath: $e');
    }
  }

  /// Get asset type from path
  static AssetType _getAssetType(String assetPath) {
    if (assetPath.endsWith('.png') ||
        assetPath.endsWith('.jpg') ||
        assetPath.endsWith('.jpeg')) {
      return AssetType.image;
    }
    if (assetPath.endsWith('.json')) {
      return AssetType.json;
    }
    if (assetPath.endsWith('.ttf') || assetPath.endsWith('.otf')) {
      return AssetType.font;
    }
    return AssetType.other;
  }

  /// Record navigation for predictive preloading
  static void recordNavigation(String screenName) {
    _navigationHistory.add(screenName);
    if (_navigationHistory.length > 10) {
      _navigationHistory.removeAt(0);
    }
    _updateTransitionProbabilities();
  }

  /// Update transition probabilities for predictive preloading
  static void _updateTransitionProbabilities() {
    if (_navigationHistory.length < 2) return;

    for (var i = 0; i < _navigationHistory.length - 1; i++) {
      final from = _navigationHistory[i];
      final to = _navigationHistory[i + 1];

      _transitionProbabilities.putIfAbsent(from, () => {});
      _transitionProbabilities[from]![to] =
          (_transitionProbabilities[from]![to] ?? 0) + 1;
    }
  }

  /// Predict next screens and preload their assets
  static Future<void> preloadPredictedAssets(BuildContext context) async {
    if (_navigationHistory.isEmpty) return;

    final currentScreen = _navigationHistory.last;
    final predictions = _predictNextScreens(currentScreen);

    for (final screen in predictions) {
      await preloadScreenAssets(context, screen);
    }
  }

  /// Predict next screens based on navigation patterns
  static List<String> _predictNextScreens(String currentScreen) {
    final transitions = _transitionProbabilities[currentScreen];
    if (transitions == null) return [];

    // Sort by probability and return top predictions
    final sorted = transitions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(3).map((e) => e.key).toList();
  }

  /// Preload assets for a specific screen
  static Future<void> preloadScreenAssets(
      BuildContext context, String screenName) async {
    final screenAssets = _getScreenAssets(screenName);

    if (screenAssets.isNotEmpty) {
      await Future.wait(
        screenAssets.map((asset) => _preloadAsset(context, asset, priority: 3)),
      );
      debugPrint('🎯 Preloaded assets for screen: $screenName');
    }
  }

  /// Get assets for a specific screen
  static List<String> _getScreenAssets(String screenName) {
    return _assetCategories.entries
        .where((entry) => _isAssetForScreen(entry.key, screenName))
        .map((entry) => entry.key)
        .toList();
  }

  /// Check if asset is relevant for a screen
  static bool _isAssetForScreen(String assetPath, String screenName) {
    final category = _assetCategories[assetPath];
    if (category == null) return false;

    switch (screenName) {
      case 'patient_dashboard':
        return [AssetCategory.patient, AssetCategory.ui, AssetCategory.common]
            .contains(category);
      case 'hospital_dashboard':
        return [AssetCategory.hospital, AssetCategory.ui, AssetCategory.common]
            .contains(category);
      case 'consultation':
        return [
          AssetCategory.consultation,
          AssetCategory.ui,
          AssetCategory.common
        ].contains(category);
      case 'medication':
        return [
          AssetCategory.medication,
          AssetCategory.ui,
          AssetCategory.common
        ].contains(category);
      case 'emergency':
        return [AssetCategory.emergency, AssetCategory.ui, AssetCategory.common]
            .contains(category);
      case 'ai_assistant':
        return [AssetCategory.ai, AssetCategory.ui, AssetCategory.common]
            .contains(category);
      default:
        return category == AssetCategory.common || category == AssetCategory.ui;
    }
  }

  /// Create dynamic asset bundle based on usage patterns
  static Future<void> createDynamicBundle(
      BuildContext context, String bundleName) async {
    final bundleAssets = _assetCategories.entries
        .where((entry) => _shouldIncludeInBundle(entry.key, bundleName))
        .map((entry) => entry.key)
        .toList();

    if (bundleAssets.isNotEmpty) {
      final bundle = DynamicAssetBundle(
        name: bundleName,
        assets: bundleAssets,
        createdAt: DateTime.now(),
      );

      // Preload bundle assets
      await Future.wait(
        bundleAssets.map((asset) => _preloadAsset(context, asset, priority: 2)),
      );

      _dynamicBundles[bundleName] = bundle;
      debugPrint(
          '📦 Created dynamic bundle: $bundleName with ${bundleAssets.length} assets');
    }
  }

  /// Determine if asset should be included in bundle
  static bool _shouldIncludeInBundle(String assetPath, String bundleName) {
    final category = _assetCategories[assetPath];
    if (category == null) return false;

    switch (bundleName) {
      case 'core':
        return [AssetCategory.critical, AssetCategory.ui, AssetCategory.common]
            .contains(category);
      case 'patient':
        return category == AssetCategory.patient;
      case 'hospital':
        return category == AssetCategory.hospital;
      case 'consultation':
        return category == AssetCategory.consultation;
      case 'medication':
        return category == AssetCategory.medication;
      case 'emergency':
        return category == AssetCategory.emergency;
      case 'ai':
        return category == AssetCategory.ai;
      default:
        return false;
    }
  }

  /// Check if asset is preloaded
  static bool isAssetPreloaded(String assetPath) {
    return _preloadedAssets.containsKey(assetPath);
  }

  /// Get preloaded asset info
  static PreloadedAsset? getPreloadedAsset(String assetPath) {
    return _preloadedAssets[assetPath];
  }

  /// Get dynamic bundle
  static DynamicAssetBundle? getDynamicBundle(String bundleName) {
    return _dynamicBundles[bundleName];
  }

  /// Clear expired preloaded assets
  static void clearExpiredAssets() {
    final expired = _preloadedAssets.entries
        .where((entry) => entry.value.isExpired)
        .map((entry) => entry.key)
        .toList();

    for (final asset in expired) {
      _preloadedAssets.remove(asset);
    }

    debugPrint('🧹 Cleared ${expired.length} expired assets');
  }

  /// Get preloading statistics
  static Map<String, dynamic> getPreloadingStats() {
    return {
      'total_discovered': _allDiscoveredAssets.length,
      'preloaded': _preloadedAssets.length,
      'critical': _criticalAssets.length,
      'frequent': _frequentAssets.length,
      'bundles': _dynamicBundles.length,
      'categories': _assetCategories.length,
    };
  }
}

/// Asset usage pattern for predictive preloading
class AssetUsagePattern {
  final String assetPath;
  final AssetCategory category;
  int accessCount;
  DateTime? lastAccessed;
  DateTime? predictedNextAccess;

  AssetUsagePattern({
    required this.assetPath,
    required this.category,
    required this.accessCount,
    this.lastAccessed,
    this.predictedNextAccess,
  });
}

/// Asset category enum
enum AssetCategory {
  critical, // Splash, icons, logos
  ui, // Buttons, cards, common UI elements
  patient, // Patient-specific assets
  hospital, // Hospital management assets
  consultation, // Video call, chat assets
  medication, // Pill, reminder assets
  emergency, // Alert, emergency assets
  ai, // AI assistant assets
  common, // General purpose assets
}

/// Dynamic asset bundle
class DynamicAssetBundle {
  final String name;
  final List<String> assets;
  final DateTime createdAt;

  DynamicAssetBundle({
    required this.name,
    required this.assets,
    required this.createdAt,
  });

  bool get isExpired {
    // Bundles expire after 24 hours
    return DateTime.now().difference(createdAt) > const Duration(hours: 24);
  }
}

/// Preloaded asset data
class PreloadedAsset {
  final String assetPath;
  final AssetType type;
  final DateTime loadedAt;
  final int priority;

  PreloadedAsset({
    required this.assetPath,
    required this.type,
    required this.loadedAt,
    this.priority = 1,
  });

  bool get isExpired {
    // Consider assets expired after 24 hours
    return DateTime.now().difference(loadedAt) > const Duration(hours: 24);
  }
}

/// Preloaded asset bundle
class PreloadedAssetBundle {
  final String name;
  final List<String> assets;
  final DateTime loadedAt;

  PreloadedAssetBundle(this.name, this.assets) : loadedAt = DateTime.now();

  bool get isExpired {
    // Consider bundles expired after 24 hours
    return DateTime.now().difference(loadedAt) > const Duration(hours: 24);
  }
}

enum AssetType {
  image,
  font,
  json,
  other,
}

/// Smart image widget with preloading support
class SmartImage extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const SmartImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Check if asset is preloaded
    final isPreloaded = AssetPreloader.isAssetPreloaded(assetPath);

    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ??
            Container(
              width: width,
              height: height,
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, color: Colors.grey),
            );
      },
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || isPreloaded) {
          return child;
        }

        // Show placeholder while loading
        return placeholder ??
            Container(
              width: width,
              height: height,
              color: Colors.grey[300],
              child: const Center(child: CircularProgressIndicator()),
            );
      },
    );
  }
}

/// Asset preloading widget that preloads assets for child widgets
class AssetPreloadingWrapper extends StatefulWidget {
  final Widget child;
  final List<String> assetsToPreload;
  final VoidCallback? onPreloadingComplete;

  const AssetPreloadingWrapper({
    super.key,
    required this.child,
    this.assetsToPreload = const [],
    this.onPreloadingComplete,
  });

  @override
  State<AssetPreloadingWrapper> createState() => _AssetPreloadingWrapperState();
}

class _AssetPreloadingWrapperState extends State<AssetPreloadingWrapper> {
  bool _isPreloading = true;

  @override
  void initState() {
    super.initState();
    _preloadAssets();
  }

  Future<void> _preloadAssets() async {
    if (widget.assetsToPreload.isEmpty) {
      setState(() {
        _isPreloading = false;
      });
      widget.onPreloadingComplete?.call();
      return;
    }

    try {
      await Future.wait(
        widget.assetsToPreload
            .map((asset) => AssetPreloader._preloadAsset(context, asset)),
      );

      if (mounted) {
        setState(() {
          _isPreloading = false;
        });
        widget.onPreloadingComplete?.call();
      }
    } catch (e) {
      debugPrint('Asset preloading failed: $e');
      if (mounted) {
        setState(() {
          _isPreloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isPreloading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading assets...'),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}

/// Extension methods for easier asset preloading
extension AssetPreloadingExtensions on BuildContext {
  /// Preload assets for a screen
  Future<void> preloadScreenAssets(String screenName) {
    return AssetPreloader.preloadScreenAssets(this, screenName);
  }

  /// Preload predicted assets based on navigation patterns
  Future<void> preloadPredictedAssets() {
    return AssetPreloader.preloadPredictedAssets(this);
  }
}
