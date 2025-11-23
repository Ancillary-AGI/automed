import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Accessibility and focus management utilities for Automed app
/// Provides comprehensive support for keyboard navigation, screen readers, and accessibility

class AccessibilityManager {
  /// Create a focus node with proper disposal management
  static FocusNode createFocusNode({
    String? debugLabel,
    FocusOnKeyEventCallback? onKeyEvent,
    bool skipTraversal = false,
    bool canRequestFocus = true,
  }) {
    return FocusNode(
      debugLabel: debugLabel,
      onKeyEvent: onKeyEvent,
      skipTraversal: skipTraversal,
      canRequestFocus: canRequestFocus,
    );
  }

  /// Create a focus scope node
  static FocusScopeNode createFocusScopeNode({
    String? debugLabel,
    FocusScopeNode? parentNode,
  }) {
    return FocusScopeNode(
      debugLabel: debugLabel,
    );
  }

  /// Request focus with proper error handling
  static void requestFocus(FocusNode? node, {bool ensureVisible = true}) {
    if (node == null || !node.canRequestFocus) return;

    try {
      node.requestFocus();
      if (ensureVisible) {
        // Ensure the focused widget is visible
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (node.context != null) {
            Scrollable.ensureVisible(
              node.context!,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: 0.5,
            );
          }
        });
      }
    } catch (e) {
      debugPrint('Failed to request focus: $e');
    }
  }

  /// Unfocus current focus
  static void unfocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Move focus to next focusable widget
  static void focusNext(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }

  /// Move focus to previous focusable widget
  static void focusPrevious(BuildContext context) {
    FocusScope.of(context).previousFocus();
  }

  /// Create logical focus group for related widgets
  static Widget createFocusGroup({
    required List<Widget> children,
    FocusTraversalPolicy? policy,
    bool skipTraversal = false,
  }) {
    return FocusTraversalGroup(
      policy: policy ?? ReadingOrderTraversalPolicy(),
      child: FocusScope(
        skipTraversal: skipTraversal,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }

  /// Create accessible button with proper semantics
  static Widget accessibleButton({
    required Widget child,
    required VoidCallback? onPressed,
    String? label,
    String? hint,
    bool excludeFromSemantics = false,
    FocusNode? focusNode,
    bool autofocus = false,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      excludeSemantics: excludeFromSemantics,
      button: true,
      enabled: onPressed != null,
      child: Focus(
        focusNode: focusNode,
        autofocus: autofocus,
        child: child,
      ),
    );
  }

  /// Create accessible text field
  static Widget accessibleTextField({
    required TextEditingController controller,
    String? label,
    String? hint,
    String? helperText,
    bool obscureText = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
    VoidCallback? onEditingComplete,
    FocusNode? focusNode,
    bool autofocus = false,
    int? maxLines = 1,
    bool enabled = true,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      textField: true,
      enabled: enabled,
      child: Focus(
        focusNode: focusNode,
        autofocus: autofocus,
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          onEditingComplete: onEditingComplete,
          maxLines: maxLines,
          enabled: enabled,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            helperText: helperText,
          ),
        ),
      ),
    );
  }

  /// Announce content to screen readers
  static void announce(String message, {String? assertiveness}) {
    // Note: SemanticsService is not available in current Flutter version
    // This is a placeholder for future implementation
    debugPrint('Accessibility announcement: $message');
  }

  /// Create tooltip with accessibility support
  static Widget accessibleTooltip({
    required String message,
    required Widget child,
    bool? excludeFromSemantics,
    bool preferBelow = true,
    Duration? waitDuration,
    EdgeInsetsGeometry? padding,
    Decoration? decoration,
    TextStyle? textStyle,
  }) {
    return Tooltip(
      message: message,
      excludeFromSemantics: excludeFromSemantics,
      preferBelow: preferBelow,
      waitDuration: waitDuration ?? const Duration(milliseconds: 0),
      padding: padding,
      decoration: decoration,
      textStyle: textStyle,
      child: Semantics(
        tooltip: message,
        child: child,
      ),
    );
  }

  /// Create accessible card
  static Widget accessibleCard({
    required Widget child,
    String? label,
    String? hint,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: onTap != null,
      enabled: enabled,
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: child,
        ),
      ),
    );
  }

  /// Create accessible list item
  static Widget accessibleListItem({
    required Widget child,
    String? label,
    String? hint,
    VoidCallback? onTap,
    bool selected = false,
    bool enabled = true,
    int? index,
    int? totalItems,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: onTap != null,
      enabled: enabled,
      selected: selected,
      child: ListTile(
        onTap: onTap,
        title: child,
      ),
    );
  }

  /// Handle keyboard shortcuts
  static Map<ShortcutActivator, Intent> getKeyboardShortcuts(
      BuildContext context) {
    return {
      // Navigation shortcuts
      LogicalKeySet(LogicalKeyboardKey.tab): const NextFocusIntent(),
      LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.tab):
          const PreviousFocusIntent(),

      // Action shortcuts
      LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
      LogicalKeySet(LogicalKeyboardKey.space): const ActivateIntent(),
      LogicalKeySet(LogicalKeyboardKey.escape): const DismissIntent(),

      // Custom shortcuts
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyR):
          const RefreshIntent(),
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS):
          const SaveIntent(),
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN):
          const NewIntent(),
    };
  }

  /// Check if screen reader is enabled
  static Future<bool> isScreenReaderEnabled() async {
    // Note: This is a simplified implementation
    // In a real app, you might use platform-specific code
    return false; // Placeholder
  }

  /// Get current text scale factor
  static double getTextScaleFactor(BuildContext context) {
    return MediaQuery.textScalerOf(context).scale(1.0);
  }

  /// Check if high contrast mode is enabled
  static bool isHighContrastEnabled(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  /// Check if bold text is enabled
  static bool isBoldTextEnabled(BuildContext context) {
    return MediaQuery.of(context).boldText;
  }

  /// Get accessible font size
  static double getAccessibleFontSize(BuildContext context, double baseSize) {
    final textScale = getTextScaleFactor(context);
    return baseSize *
        textScale.clamp(0.8, 2.0); // Limit scaling for readability
  }

  /// Create accessible color scheme
  static ColorScheme getAccessibleColorScheme(ColorScheme baseScheme) {
    // Simplified implementation - return base scheme as-is
    // In a real implementation, you would calculate proper contrast ratios
    return baseScheme;
  }
}

/// Custom intents for keyboard shortcuts
class RefreshIntent extends Intent {
  const RefreshIntent();
}

class SaveIntent extends Intent {
  const SaveIntent();
}

class NewIntent extends Intent {
  const NewIntent();
}

/// Focus management widget
class FocusManager extends StatefulWidget {
  final Widget child;
  final FocusNode? initialFocus;
  final bool autofocus;

  const FocusManager({
    super.key,
    required this.child,
    this.initialFocus,
    this.autofocus = false,
  });

  @override
  State<FocusManager> createState() => _FocusManagerState();
}

class _FocusManagerState extends State<FocusManager> {
  final Map<String, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    if (widget.autofocus && widget.initialFocus != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AccessibilityManager.requestFocus(widget.initialFocus);
      });
    }
  }

  @override
  void dispose() {
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    _focusNodes.clear();
    super.dispose();
  }

  FocusNode getOrCreateFocusNode(String key) {
    return _focusNodes[key] ??= AccessibilityManager.createFocusNode(
      debugLabel: key,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      child: Shortcuts(
        shortcuts: AccessibilityManager.getKeyboardShortcuts(context),
        child: Actions(
          actions: {
            RefreshIntent: CallbackAction<RefreshIntent>(
              onInvoke: (intent) => _handleRefresh(context),
            ),
            SaveIntent: CallbackAction<SaveIntent>(
              onInvoke: (intent) => _handleSave(context),
            ),
            NewIntent: CallbackAction<NewIntent>(
              onInvoke: (intent) => _handleNew(context),
            ),
          },
          child: widget.child,
        ),
      ),
    );
  }

  void _handleRefresh(BuildContext context) {
    // Implement refresh logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Refreshing...')),
    );
  }

  void _handleSave(BuildContext context) {
    // Implement save logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saving...')),
    );
  }

  void _handleNew(BuildContext context) {
    // Implement new item logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Creating new item...')),
    );
  }
}

/// Accessible navigation widget
class AccessibleNavigation extends StatelessWidget {
  final List<NavigationItem> items;
  final int currentIndex;
  final ValueChanged<int> onItemSelected;
  final NavigationType navigationType;

  const AccessibleNavigation({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onItemSelected,
    required this.navigationType,
  });

  @override
  Widget build(BuildContext context) {
    switch (navigationType) {
      case NavigationType.bottomNavigation:
        return _buildBottomNavigationBar(context);
      case NavigationType.navigationRail:
        return _buildNavigationRail(context);
      case NavigationType.navigationDrawer:
        return _buildNavigationDrawer(context);
    }
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      items: items
          .map((item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                label: item.label,
                tooltip: item.tooltip,
              ))
          .toList(),
      currentIndex: currentIndex,
      onTap: onItemSelected,
      type: BottomNavigationBarType.fixed,
    );
  }

  Widget _buildNavigationRail(BuildContext context) {
    return NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: onItemSelected,
      labelType: NavigationRailLabelType.all,
      destinations: items
          .map((item) => NavigationRailDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon ?? item.icon),
                label: Text(item.label),
              ))
          .toList(),
    );
  }

  Widget _buildNavigationDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            child: Text('Navigation'),
          ),
          ...items.asMap().entries.map((entry) => ListTile(
                leading: Icon(entry.value.icon),
                title: Text(entry.value.label),
                selected: entry.key == currentIndex,
                onTap: () => onItemSelected(entry.key),
              )),
        ],
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final String? tooltip;

  const NavigationItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.tooltip,
  });
}

enum NavigationType {
  bottomNavigation,
  navigationRail,
  navigationDrawer,
}

/// Extension methods for accessibility
extension AccessibilityExtensions on BuildContext {
  void announce(String message, {String? assertiveness}) {
    AccessibilityManager.announce(message, assertiveness: assertiveness);
  }

  void requestFocus(FocusNode? node, {bool ensureVisible = true}) {
    AccessibilityManager.requestFocus(node, ensureVisible: ensureVisible);
  }

  void unfocus() {
    AccessibilityManager.unfocus(this);
  }

  void focusNext() {
    AccessibilityManager.focusNext(this);
  }

  void focusPrevious() {
    AccessibilityManager.focusPrevious(this);
  }

  double get accessibleFontSize =>
      AccessibilityManager.getAccessibleFontSize(this, 14.0);

  bool get isHighContrastEnabled =>
      AccessibilityManager.isHighContrastEnabled(this);

  bool get isBoldTextEnabled => AccessibilityManager.isBoldTextEnabled(this);

  Future<bool> get isScreenReaderEnabled =>
      AccessibilityManager.isScreenReaderEnabled();
}
