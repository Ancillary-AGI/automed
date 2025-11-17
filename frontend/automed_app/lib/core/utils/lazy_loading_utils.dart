import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// AJAX-like lazy loading utilities for Automed app
/// Provides infinite scrolling, pull-to-refresh, and smart caching

class LazyLoadingController<T> extends StateNotifier<LazyLoadingState<T>> {
  final Future<List<T>> Function(int page, int pageSize) fetchFunction;
  final int pageSize;
  final Duration cacheDuration;
  final bool enablePreloading;
  final int preloadThreshold;

  LazyLoadingController({
    required this.fetchFunction,
    this.pageSize = 20,
    this.cacheDuration = const Duration(minutes: 5),
    this.enablePreloading = true,
    this.preloadThreshold = 5,
  }) : super(LazyLoadingState<T>()) {
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = await fetchFunction(0, pageSize);
      state = LazyLoadingState<T>(
        items: data,
        currentPage: 0,
        hasMoreData: data.length >= pageSize,
        isLoading: false,
        lastFetchTime: DateTime.now(),
      );

      // Start preloading next page
      if (enablePreloading && data.length >= pageSize) {
        unawaited(preloadNextPage());
      }
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error);
    }
  }

  Future<void> loadMoreData() async {
    if (state.isLoading || !state.hasMoreData) return;

    // Check if we have preloaded data
    if (state.preloadedData != null &&
        state.preloadedPage == state.currentPage + 1) {
      state = state.copyWith(
        items: [...state.items, ...state.preloadedData!],
        currentPage: state.preloadedPage!,
        hasMoreData: state.preloadedData!.length >= pageSize,
        isLoading: false,
        lastFetchTime: DateTime.now(),
        preloadedData: null,
        preloadedPage: null,
      );

      // Start preloading next page
      if (enablePreloading) {
        unawaited(preloadNextPage());
      }
      return;
    }

    // Regular loading
    state = state.copyWith(isLoading: true, error: null);

    try {
      final nextPage = state.currentPage + 1;
      final newData = await fetchFunction(nextPage, pageSize);

      state = state.copyWith(
        items: [...state.items, ...newData],
        currentPage: nextPage,
        hasMoreData: newData.length >= pageSize,
        isLoading: false,
        lastFetchTime: DateTime.now(),
      );

      // Start preloading next page
      if (enablePreloading) {
        unawaited(preloadNextPage());
      }
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error);
    }
  }

  Future<void> refreshData() async {
    state = LazyLoadingState<T>();
    await loadInitialData();
  }

  bool get isCacheValid {
    if (state.lastFetchTime == null) return false;
    return DateTime.now().difference(state.lastFetchTime!) < cacheDuration;
  }

  void invalidateCache() {
    state = state.copyWith(lastFetchTime: null);
  }

  /// Public getter for current state
  LazyLoadingState<T> get currentState => state;

  /// Preload next page in background
  Future<void> preloadNextPage() async {
    if (!enablePreloading || state.isLoading || !state.hasMoreData) return;

    try {
      final nextPage = state.currentPage + 1;
      final preloadedData = await fetchFunction(nextPage, pageSize);

      // Store preloaded data for immediate use
      state = state.copyWith(
        preloadedData: preloadedData,
        preloadedPage: nextPage,
      );
    } catch (e) {
      debugPrint('Failed to preload next page: $e');
    }
  }
}

class LazyLoadingState<T> {
  final List<T> items;
  final int currentPage;
  final bool hasMoreData;
  final bool isLoading;
  final Object? error;
  final DateTime? lastFetchTime;
  final List<T>? preloadedData;
  final int? preloadedPage;

  LazyLoadingState({
    this.items = const [],
    this.currentPage = 0,
    this.hasMoreData = true,
    this.isLoading = false,
    this.error,
    this.lastFetchTime,
    this.preloadedData,
    this.preloadedPage,
  });

  LazyLoadingState<T> copyWith({
    List<T>? items,
    int? currentPage,
    bool? hasMoreData,
    bool? isLoading,
    Object? error,
    DateTime? lastFetchTime,
    List<T>? preloadedData,
    int? preloadedPage,
  }) {
    return LazyLoadingState<T>(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastFetchTime: lastFetchTime ?? this.lastFetchTime,
      preloadedData: preloadedData ?? this.preloadedData,
      preloadedPage: preloadedPage ?? this.preloadedPage,
    );
  }
}

/// Infinite scroll list view with AJAX-like loading
class LazyLoadingListView<T> extends StatefulWidget {
  final LazyLoadingController<T> controller;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? emptyWidget;
  final double loadMoreThreshold;
  final ScrollController? scrollController;

  const LazyLoadingListView({
    super.key,
    required this.controller,
    required this.itemBuilder,
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
    this.loadMoreThreshold = 200.0,
    this.scrollController,
  });

  @override
  State<LazyLoadingListView<T>> createState() => _LazyLoadingListViewState<T>();
}

class _LazyLoadingListViewState<T> extends State<LazyLoadingListView<T>> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - widget.loadMoreThreshold) {
      widget.controller.loadMoreData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final state = widget.controller.currentState;

        if (state.error != null && state.items.isEmpty) {
          return widget.errorWidget ??
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${state.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: widget.controller.refreshData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
        }

        if (state.items.isEmpty && !state.isLoading) {
          return widget.emptyWidget ??
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No data available'),
                  ],
                ),
              );
        }

        return RefreshIndicator(
          onRefresh: widget.controller.refreshData,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: state.items.length + (state.hasMoreData ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == state.items.length) {
                // Loading indicator
                return widget.loadingWidget ??
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
              }

              return widget.itemBuilder(context, state.items[index], index);
            },
          ),
        );
      },
    );
  }
}

/// Grid view with lazy loading
class LazyLoadingGridView<T> extends StatefulWidget {
  final LazyLoadingController<T> controller;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final int crossAxisCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? emptyWidget;
  final double loadMoreThreshold;

  const LazyLoadingGridView({
    super.key,
    required this.controller,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
    this.loadMoreThreshold = 200.0,
  });

  @override
  State<LazyLoadingGridView<T>> createState() => _LazyLoadingGridViewState<T>();
}

class _LazyLoadingGridViewState<T> extends State<LazyLoadingGridView<T>> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - widget.loadMoreThreshold) {
      widget.controller.loadMoreData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final state = widget.controller.currentState;

        if (state.error != null && state.items.isEmpty) {
          return widget.errorWidget ??
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${state.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: widget.controller.refreshData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
        }

        if (state.items.isEmpty && !state.isLoading) {
          return widget.emptyWidget ??
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No data available'),
                  ],
                ),
              );
        }

        return RefreshIndicator(
          onRefresh: widget.controller.refreshData,
          child: GridView.builder(
            controller: _scrollController,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.crossAxisCount,
              childAspectRatio: widget.childAspectRatio,
              crossAxisSpacing: widget.crossAxisSpacing,
              mainAxisSpacing: widget.mainAxisSpacing,
            ),
            itemCount: state.items.length + (state.hasMoreData ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == state.items.length) {
                // Loading indicator
                return widget.loadingWidget ??
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
              }

              return widget.itemBuilder(context, state.items[index], index);
            },
          ),
        );
      },
    );
  }
}

/// Smart caching utilities for network assets
class AssetCacheManager {
  static final Map<String, CachedAsset> _cache = {};
  static final Map<String, int> _accessCount = {};
  static const Duration defaultCacheDuration = Duration(hours: 24);
  static const int maxCacheSize = 100;

  static Future<CachedAsset?> getCachedAsset(String url) async {
    final cached = _cache[url];
    if (cached != null && !cached.isExpired) {
      // Update access count for LRU
      _accessCount[url] = (_accessCount[url] ?? 0) + 1;
      cached.lastAccessed = DateTime.now();
      return cached;
    }
    return null;
  }

  static void cacheAsset(String url, dynamic data, {Duration? duration}) {
    // Implement LRU eviction if cache is full
    if (_cache.length >= maxCacheSize) {
      _evictLRU();
    }

    _cache[url] = CachedAsset(
      data: data,
      expiryTime: DateTime.now().add(duration ?? defaultCacheDuration),
    );
    _accessCount[url] = 1;
  }

  static void _evictLRU() {
    if (_cache.isEmpty) return;

    String? lruKey;
    DateTime? oldestAccess;

    for (final entry in _cache.entries) {
      final accessTime = entry.value.lastAccessed;
      if (oldestAccess == null || accessTime.isBefore(oldestAccess)) {
        oldestAccess = accessTime;
        lruKey = entry.key;
      }
    }

    if (lruKey != null) {
      _cache.remove(lruKey);
      _accessCount.remove(lruKey);
    }
  }

  static void clearExpiredCache() {
    _cache.removeWhere((key, value) => value.isExpired);
    _accessCount.removeWhere((key, value) => !_cache.containsKey(key));
  }

  static void clearCache() {
    _cache.clear();
    _accessCount.clear();
  }

  static int getCacheSize() => _cache.length;

  static Map<String, int> getCacheStats() => Map.from(_accessCount);
}

class CachedAsset {
  final dynamic data;
  final DateTime expiryTime;
  DateTime lastAccessed;

  CachedAsset({
    required this.data,
    required this.expiryTime,
  }) : lastAccessed = DateTime.now();

  bool get isExpired => DateTime.now().isAfter(expiryTime);
}

/// Preloading utilities for asset bundles
class AssetPreloader {
  static final Set<String> _preloadedAssets = {};

  static Future<void> preloadImage(
      BuildContext context, String assetPath) async {
    if (_preloadedAssets.contains(assetPath)) return;

    try {
      await precacheImage(AssetImage(assetPath), context);
      _preloadedAssets.add(assetPath);
    } catch (e) {
      debugPrint('Failed to preload image: $assetPath');
    }
  }

  static Future<void> preloadImages(
      BuildContext context, List<String> assetPaths) async {
    await Future.wait(
      assetPaths.map((path) => preloadImage(context, path)),
    );
  }

  static void clearPreloadedAssets() {
    _preloadedAssets.clear();
  }
}

/// Smart image widget with lazy loading and caching
class SmartNetworkImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Duration cacheDuration;
  final bool enableCaching;

  const SmartNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.cacheDuration = const Duration(hours: 24),
    this.enableCaching = true,
  });

  @override
  State<SmartNetworkImage> createState() => _SmartNetworkImageState();
}

class _SmartNetworkImageState extends State<SmartNetworkImage> {
  ImageProvider? _imageProvider;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(SmartNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      if (widget.enableCaching) {
        final cached = await AssetCacheManager.getCachedAsset(widget.imageUrl);
        if (cached != null) {
          _imageProvider = cached.data as ImageProvider;
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      _imageProvider = NetworkImage(widget.imageUrl);

      // Preload the image
      final imageStream = _imageProvider!.resolve(ImageConfiguration.empty);
      imageStream.addListener(ImageStreamListener(
        (info, synchronousCall) {
          if (widget.enableCaching && mounted) {
            AssetCacheManager.cacheAsset(
              widget.imageUrl,
              _imageProvider,
              duration: widget.cacheDuration,
            );
          }
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        },
        onError: (exception, stackTrace) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          }
        },
      ));
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return widget.errorWidget ??
          Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
    }

    if (_isLoading) {
      return widget.placeholder ??
          Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey[300],
            child: const Center(child: CircularProgressIndicator()),
          );
    }

    return Image(
      image: _imageProvider!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        return widget.errorWidget ??
            Container(
              width: widget.width,
              height: widget.height,
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, color: Colors.grey),
            );
      },
    );
  }
}
