import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:automed_app/core/theme/app_colors.dart';
import 'package:automed_app/core/utils/responsive_utils.dart';
import 'package:automed_app/core/providers/theme_provider.dart';
import 'package:automed_app/core/di/injection.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.appPrimary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: context.responsivePadding,
        children: [
          _buildSection(
            context,
            'Account',
            [
              _buildSettingItem(
                context,
                'Profile',
                Icons.person,
                () => context.go('/settings/profile'),
              ),
              _buildSettingItem(
                context,
                'Notifications',
                Icons.notifications,
                () => context.go('/settings/notifications'),
              ),
              _buildSettingItem(
                context,
                'Privacy',
                Icons.security,
                () => context.go('/settings/privacy'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            'App Settings',
            [
              _buildSettingItem(
                context,
                'Appearance',
                Icons.palette,
                () => _showAppearanceDialog(context),
              ),
              _buildSettingItem(
                context,
                'Language',
                Icons.language,
                () => _showLanguageDialog(context),
              ),
              _buildSettingItem(
                context,
                'Accessibility',
                Icons.accessibility,
                () => _showAccessibilityDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            'Support',
            [
              _buildSettingItem(
                context,
                'Help & Support',
                Icons.help,
                () => _showHelpDialog(context),
              ),
              _buildSettingItem(
                context,
                'About',
                Icons.info,
                () => _showAboutDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            'Account Actions',
            [
              _buildSettingItem(
                context,
                'Logout',
                Icons.logout,
                () => _showLogoutDialog(context),
                color: AppColors.appError,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> items) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.appPrimary,
                  ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.appPrimary),
      title: Text(title),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }

  void _showAppearanceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final currentTheme = ref.watch(themeProvider);

          return AlertDialog(
            title: const Text('Appearance'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Choose your preferred theme:'),
                const SizedBox(height: 16),
                _buildThemeOption(
                  context,
                  ref,
                  'System',
                  'Follow system setting',
                  ThemeModeOption.system,
                  currentTheme,
                ),
                _buildThemeOption(
                  context,
                  ref,
                  'Light',
                  'Always use light theme',
                  ThemeModeOption.light,
                  currentTheme,
                ),
                _buildThemeOption(
                  context,
                  ref,
                  'Dark',
                  'Always use dark theme',
                  ThemeModeOption.dark,
                  currentTheme,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    String title,
    String subtitle,
    ThemeModeOption option,
    ThemeModeOption currentTheme,
  ) {
    return RadioMenuButton<ThemeModeOption>(
      value: option,
      groupValue: currentTheme,
      onChanged: (value) {
        if (value != null) {
          ref.read(themeProvider.notifier).setThemeMode(value);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withValues(alpha: 0.7),
                ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose your preferred language:'),
            const SizedBox(height: 16),
            _buildLanguageOption(context, 'English', const Locale('en')),
            _buildLanguageOption(context, 'Español', const Locale('es')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
      BuildContext context, String languageName, Locale locale) {
    return ListTile(
      title: Text(languageName),
      onTap: () {
        // Note: In a real app, you would use a localization service
        // For now, we'll just show a message
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Language changed to $languageName. Restart the app to see changes.'),
            duration: const Duration(seconds: 3),
          ),
        );
      },
    );
  }

  void _showAccessibilityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accessibility'),
        content: const Text('Accessibility settings will be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content:
            const Text('Help and support options will be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Automed'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Automed - Global Healthcare Delivery Automation Platform'),
            SizedBox(height: 8),
            Text('Version: 1.0.0'),
            Text('© 2024 Automed Inc.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          Consumer(
            builder: (context, ref, child) => TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performLogout(context, ref);
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.appError,
              ),
              child: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout(BuildContext context, WidgetRef ref) async {
    try {
      // Get auth service from provider
      final authService = ref.read(authServiceProvider);

      // Perform logout
      await authService.logout();

      // Clear any cached data if needed
      // Navigate to login screen
      if (context.mounted) {
        context.go('/login');
      }
    } catch (e) {
      // Show error if logout fails
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: AppColors.appError,
          ),
        );
      }
    }
  }
}
