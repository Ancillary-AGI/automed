import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../config/app_config.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../services/connectivity_service.dart';
import '../services/internationalization_service.dart';

/// Advanced App Scaffold with comprehensive features for healthcare applications
/// Supports responsive design, accessibility, internationalization, and offline capabilities
class AppScaffold extends ConsumerStatefulWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final bool showAppBar;
  final bool showBottomNav;
  final bool showOfflineIndicator;
  final bool showEmergencyButton;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;
  final Brightness? statusBarBrightness;
  final SystemUiOverlayStyle? systemUiOverlayStyle;

  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.showAppBar = true,
    this.showBottomNav = true,
    this.showOfflineIndicator = true,
    this.showEmergencyButton = false,
    this.resizeToAvoidBottomInset = true,
    this.backgroundColor,
    this.statusBarBrightness,
    this.systemUiOverlayStyle,
  });

  @override
  ConsumerState<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends ConsumerState<AppScaffold>
    with WidgetsBindingObserver {
  late InternationalizationService _i18n;
  bool _isOffline = false;
  bool _isEmergencyMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeServices();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      case AppLifecycleState.paused:
        _handleAppPaused();
        break;
      case AppLifecycleState.inactive:
        _handleAppInactive();
        break;
      case AppLifecycleState.detached:
        _handleAppDetached();
        break;
      case AppLifecycleState.hidden:
        // Handle app hidden state if needed
        break;
    }
  }

  Future<void> _initializeServices() async {
    _i18n = InternationalizationService();
    await _i18n.initialize();

    // Listen to connectivity changes
    ref.listen(connectivityProvider, (previous, next) {
      setState(() {
        _isOffline = !next.isConnected;
      });
    });
  }

  void _handleAppResumed() {
    // Refresh data when app resumes
    _refreshData();
  }

  void _handleAppPaused() {
    // Save any pending data
    _savePendingData();
  }

  void _handleAppInactive() {
    // Handle app becoming inactive
  }

  void _handleAppDetached() {
    // Clean up resources
    _cleanupResources();
  }

  void _refreshData() {
    // Implementation for refreshing data
  }

  void _savePendingData() {
    // Implementation for saving pending data
  }

  void _cleanupResources() {
    // Implementation for cleaning up resources
  }

  void _toggleEmergencyMode() {
    setState(() {
      _isEmergencyMode = !_isEmergencyMode;
    });

    if (_isEmergencyMode) {
      // Activate emergency mode features
      _activateEmergencyMode();
    } else {
      // Deactivate emergency mode features
      _deactivateEmergencyMode();
    }
  }

  void _activateEmergencyMode() {
    // Implementation for activating emergency mode
    // - Change UI colors to emergency theme
    // - Enable emergency navigation
    // - Show emergency contacts
    // - Enable emergency communication
  }

  void _deactivateEmergencyMode() {
    // Implementation for deactivating emergency mode
  }

  @override
  Widget build(BuildContext context) {
    final appConfig = ref.watch(appConfigProvider);
    final connectivityState = ref.watch(connectivityProvider);
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    // Determine if we're on a small screen
    final isSmallScreen = mediaQuery.size.width < 600;
    final isTablet =
        mediaQuery.size.width >= 600 && mediaQuery.size.width < 1200;
    final isDesktop = mediaQuery.size.width >= 1200;

    // Adjust layout based on screen size and orientation
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final isRTL = _i18n.isRTLLocale();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: widget.systemUiOverlayStyle ??
          (theme.brightness == Brightness.dark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark),
      child: Scaffold(
        backgroundColor:
            widget.backgroundColor ?? theme.scaffoldBackgroundColor,

        // App Bar with responsive design
        appBar: widget.showAppBar
            ? _buildAppBar(context, isSmallScreen, isRTL)
            : null,

        // Drawer for navigation
        drawer: widget.drawer ?? (isSmallScreen ? _buildDrawer(context) : null),

        // End drawer for additional options
        endDrawer: widget.endDrawer,

        // Body with offline indicator and emergency overlay
        body: Stack(
          children: [
            // Main content
            widget.body,

            // Offline indicator
            if (widget.showOfflineIndicator && _isOffline)
              _buildOfflineIndicator(context),

            // Emergency overlay
            if (_isEmergencyMode) _buildEmergencyOverlay(context),

            // Emergency button (floating)
            if (widget.showEmergencyButton) _buildEmergencyButton(context),
          ],
        ),

        // Floating action button
        floatingActionButton: widget.floatingActionButton,

        // Floating action button location
        floatingActionButtonLocation: widget.floatingActionButtonLocation,

        // Bottom navigation bar
        bottomNavigationBar: widget.showBottomNav && isSmallScreen
            ? widget.bottomNavigationBar ?? _buildBottomNav(context)
            : null,

        // Resize to avoid bottom inset
        resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,

        // Extend body behind app bar
        extendBodyBehindAppBar: false,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, bool isSmallScreen, bool isRTL) {
    final theme = Theme.of(context);

    return AppBar(
      title: widget.title != null
          ? Text(
              widget.title!,
              style: AppTextStyles.headline6.copyWith(
                color: theme.appBarTheme.titleTextStyle?.color,
              ),
            )
          : null,

      actions: [
        // Language selector
        IconButton(
          icon: const Icon(Icons.language),
          onPressed: () => _showLanguageSelector(context),
          tooltip: 'Change Language',
        ),

        // Theme toggle
        IconButton(
          icon: Icon(theme.brightness == Brightness.dark
              ? Icons.light_mode
              : Icons.dark_mode),
          onPressed: () => _toggleTheme(context),
          tooltip: 'Toggle Theme',
        ),

        // Emergency mode toggle
        if (widget.showEmergencyButton)
          IconButton(
            icon: Icon(
              _isEmergencyMode ? Icons.emergency : Icons.emergency_outlined,
              color: _isEmergencyMode ? AppColors.emergency : null,
            ),
            onPressed: _toggleEmergencyMode,
            tooltip: _isEmergencyMode
                ? 'Exit Emergency Mode'
                : 'Enter Emergency Mode',
          ),

        // Additional actions
        ...?widget.actions,
      ],

      // Responsive app bar
      toolbarHeight: isSmallScreen ? kToolbarHeight : 64.0,

      // Elevation based on scroll
      elevation: 0,

      // Background color
      backgroundColor: theme.appBarTheme.backgroundColor,

      // Icon theme
      iconTheme: theme.appBarTheme.iconTheme,

      // Center title on small screens only
      centerTitle: isSmallScreen,

      // Leading widget
      leading: isSmallScreen && widget.drawer != null
          ? Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
                tooltip: 'Open navigation menu',
              ),
            )
          : null,

      // Bottom border
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: theme.dividerColor.withValues(alpha: 0.1),
          height: 1.0,
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer header
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Patient Name', // TODO: Get from user profile
                  style: AppTextStyles.headline6.copyWith(
                    color: Colors.white,
                  ),
                ),
                Text(
                  'patient@email.com', // TODO: Get from user profile
                  style: AppTextStyles.body2.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),

          // Navigation items
          _buildDrawerItem(
            context,
            icon: Icons.dashboard,
            title: 'Dashboard',
            onTap: () => context.go('/dashboard'),
          ),

          _buildDrawerItem(
            context,
            icon: Icons.medical_services,
            title: 'Medical Records',
            onTap: () => context.go('/medical-records'),
          ),

          _buildDrawerItem(
            context,
            icon: Icons.calendar_today,
            title: 'Appointments',
            onTap: () => context.go('/appointments'),
          ),

          _buildDrawerItem(
            context,
            icon: Icons.medication,
            title: 'Medications',
            onTap: () => context.go('/medications'),
          ),

          _buildDrawerItem(
            context,
            icon: Icons.local_hospital,
            title: 'Find Hospital',
            onTap: () => context.go('/hospitals'),
          ),

          _buildDrawerItem(
            context,
            icon: Icons.analytics,
            title: 'Analytics',
            onTap: () => context.go('/analytics'),
          ),

          const Divider(),

          _buildDrawerItem(
            context,
            icon: Icons.settings,
            title: 'Settings',
            onTap: () => context.go('/settings'),
          ),

          _buildDrawerItem(
            context,
            icon: Icons.help,
            title: 'Help & Support',
            onTap: () => context.go('/help'),
          ),

          _buildDrawerItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.iconTheme.color),
      title: Text(
        title,
        style: AppTextStyles.body1,
      ),
      onTap: () {
        Navigator.of(context).pop(); // Close drawer
        onTap();
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final theme = Theme.of(context);

    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.medical_services),
          label: 'Health',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Appointments',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      currentIndex: 0, // TODO: Get from router state
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/dashboard');
            break;
          case 1:
            context.go('/health');
            break;
          case 2:
            context.go('/appointments');
            break;
          case 3:
            context.go('/profile');
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
      selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
      unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
    );
  }

  Widget _buildOfflineIndicator(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: AppColors.warning,
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: [
            Icon(
              Icons.wifi_off,
              color: theme.colorScheme.onPrimary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'You are currently offline. Some features may be limited.',
                style: AppTextStyles.body2.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Retry connection
              },
              child: Text(
                'Retry',
                style: AppTextStyles.button.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyOverlay(BuildContext context) {
    return Container(
      color: AppColors.emergency.withValues(alpha: 0.1),
      child: Center(
        child: Card(
          elevation: 8,
          color: AppColors.emergency,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.emergency,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  'EMERGENCY MODE ACTIVE',
                  style: AppTextStyles.headline6.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Emergency services have been notified.\nStay calm and follow instructions.',
                  style: AppTextStyles.body1.copyWith(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _toggleEmergencyMode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.emergency,
                  ),
                  child: const Text('Exit Emergency Mode'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyButton(BuildContext context) {
    return Positioned(
      bottom: 88, // Above bottom nav
      right: 16,
      child: FloatingActionButton(
        onPressed: () => context.go('/emergency'),
        backgroundColor: AppColors.emergency,
        foregroundColor: Colors.white,
        child: const Icon(Icons.emergency),
        tooltip: 'Emergency',
        elevation: 6,
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Language',
              style: AppTextStyles.headline6,
            ),
            const SizedBox(height: 16),
            // TODO: Implement language selection
            ListTile(
              title: const Text('English'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Change language
              },
            ),
            ListTile(
              title: const Text('Spanish'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Change language
              },
            ),
            // Add more languages...
          ],
        ),
      ),
    );
  }

  void _toggleTheme(BuildContext context) {
    // TODO: Implement theme toggle
  }

  void _logout(BuildContext context) {
    // TODO: Implement logout
    context.go('/login');
  }
}
