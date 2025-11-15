import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../generated/l10n.dart';
import '../providers/emergency_provider.dart';
import '../widgets/emergency_button.dart';
import '../widgets/emergency_contacts_list.dart';
import '../widgets/location_widget.dart';

class EmergencyScreen extends ConsumerStatefulWidget {
  const EmergencyScreen({super.key});

  @override
  ConsumerState<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends ConsumerState<EmergencyScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Position? _currentPosition;
  bool _isEmergencyActive = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Permission.location.request();
      if (permission.isGranted) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          _currentPosition = position;
        });
      }
    } catch (e) {
      // Handle location error
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      backgroundColor: _isEmergencyActive ? Colors.red[50] : null,
      title: S.of(context).emergency,
      actions: [
        if (_isEmergencyActive)
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: _cancelEmergency,
          ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Emergency Status
            if (_isEmergencyActive)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red, width: 2),
                ),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Icon(
                            Icons.warning,
                            color: Colors.red,
                            size: 48,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      S.of(context).emergencyActive,
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: Colors.red[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      S.of(context).helpIsOnTheWay,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.red[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

            // Emergency Button
            Center(
              child: EmergencyButton(
                onPressed:
                    _isEmergencyActive ? _cancelEmergency : _triggerEmergency,
              ),
            ),

            const SizedBox(height: 32),

            // Location Information
            if (_currentPosition != null)
              LocationWidget(
                address:
                    '${_currentPosition!.latitude}, ${_currentPosition!.longitude}',
              ),

            const SizedBox(height: 24),

            // Emergency Instructions
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        S.of(context).emergencyInstructions,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInstructionItem(
                    S.of(context).stayCalm,
                    Icons.psychology,
                  ),
                  _buildInstructionItem(
                    S.of(context).provideLocation,
                    Icons.location_on,
                  ),
                  _buildInstructionItem(
                    S.of(context).followDispatcherInstructions,
                    Icons.headset_mic,
                  ),
                  _buildInstructionItem(
                    S.of(context).keepPhoneNearby,
                    Icons.phone,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Emergency Contacts
            EmergencyContactsList(
              contacts: ['Emergency: 911', 'Police: 911', 'Fire: 911'],
            ),

            const SizedBox(height: 24),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.local_hospital,
                    label: S.of(context).nearestHospital,
                    onTap: _findNearestHospital,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.medical_services,
                    label: S.of(context).medicalInfo,
                    onTap: _showMedicalInfo,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _triggerEmergency() {
    setState(() {
      _isEmergencyActive = true;
    });

    ref.read(emergencyProvider.notifier).triggerEmergency(
          location: _currentPosition,
        );

    // Show confirmation dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).emergencyTriggered),
        content: Text(S.of(context).emergencyServicesNotified),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(S.of(context).ok),
          ),
        ],
      ),
    );
  }

  void _cancelEmergency() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).cancelEmergency),
        content: Text(S.of(context).cancelEmergencyConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(S.of(context).no),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _isEmergencyActive = false;
              });
              ref.read(emergencyProvider.notifier).cancelEmergency();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(S.of(context).yes),
          ),
        ],
      ),
    );
  }

  void _findNearestHospital() {
    // Implement find nearest hospital functionality
  }

  void _showMedicalInfo() {
    // Show medical information dialog
  }
}
