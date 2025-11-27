import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:automed_app/core/theme/app_text_styles.dart';
import 'package:automed_app/core/widgets/app_scaffold.dart';
import 'package:automed_app/core/services/background_location_service.dart';
import 'package:automed_app/core/models/hospital_models.dart';
import 'package:automed_app/core/models/patient_models.dart';
import 'package:automed_app/generated/l10n.dart';
import 'package:automed_app/features/emergency/presentation/providers/emergency_provider.dart';
import 'package:automed_app/features/emergency/presentation/widgets/emergency_button.dart';
import 'package:automed_app/features/emergency/presentation/widgets/emergency_contacts_list.dart';
import 'package:automed_app/features/emergency/presentation/widgets/location_widget.dart';

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
                          child: const Icon(
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
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
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
            const EmergencyContactsList(
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
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
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

  void _triggerEmergency() async {
    setState(() {
      _isEmergencyActive = true;
    });

    ref.read(emergencyProvider.notifier).triggerEmergency(
          location: _currentPosition,
        );

    // Start background location tracking
    await BackgroundLocationService.startEmergencyTracking();

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

  void _cancelEmergency() async {
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
            onPressed: () async {
              setState(() {
                _isEmergencyActive = false;
              });
              ref.read(emergencyProvider.notifier).cancelEmergency();
              await BackgroundLocationService.stopEmergencyTracking();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(S.of(context).yes),
          ),
        ],
      ),
    );
  }

  void _findNearestHospital() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location not available')),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Finding nearest hospitals...'),
          ],
        ),
      ),
    );

    try {
      // Call API to find nearest hospitals
      // For now, return mock hospitals - in production this would call the actual API
      final hospitals = await _getMockHospitals();

      Navigator.of(context).pop(); // Close loading dialog

      if (hospitals.isEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('No Hospitals Found'),
            content: const Text('No hospitals found nearby your location.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      // Show hospital selection dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Nearest Hospitals'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: hospitals.length,
              itemBuilder: (context, index) {
                final hospital = hospitals[index];
                final distance = _calculateDistance(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                  hospital.address.latitude ?? _currentPosition!.latitude,
                  hospital.address.longitude ?? _currentPosition!.longitude,
                );

                return ListTile(
                  leading: const Icon(Icons.local_hospital, color: Colors.red),
                  title: Text(hospital.name),
                  subtitle: Text('${distance.toStringAsFixed(1)} km away'),
                  trailing: IconButton(
                    icon: const Icon(Icons.directions),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _openDirections(hospital);
                    },
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showHospitalDetails(hospital);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(S.of(context).close),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Failed to find hospitals. Please try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<List<Hospital>> _getMockHospitals() async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Return mock hospitals near the user's location
    final baseLat = _currentPosition!.latitude;
    final baseLon = _currentPosition!.longitude;

    return [
      Hospital(
        id: '1',
        name: 'City General Hospital',
        type: 'GENERAL',
        address: Address(
          street: '123 Main St',
          city: 'City Center',
          state: 'State',
          country: 'Country',
          zipCode: '12345',
          latitude: baseLat + 0.01,
          longitude: baseLon + 0.01,
        ),
        phoneNumber: '+1-555-0101',
        specialties: ['Emergency Medicine', 'Cardiology', 'Surgery'],
        status: HospitalStatus.active,
        capacity: 500,
        currentOccupancy: 350,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now(),
      ),
      Hospital(
        id: '2',
        name: 'Regional Medical Center',
        type: 'GENERAL',
        address: Address(
          street: '456 Health Ave',
          city: 'Medical District',
          state: 'State',
          country: 'Country',
          zipCode: '12346',
          latitude: baseLat - 0.005,
          longitude: baseLon + 0.008,
        ),
        phoneNumber: '+1-555-0102',
        specialties: ['Emergency Medicine', 'Neurology', 'Oncology'],
        status: HospitalStatus.active,
        capacity: 300,
        currentOccupancy: 200,
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = (lat2 - lat1) * (math.pi / 180);
    final double dLon = (lon2 - lon1) * (math.pi / 180);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  void _openDirections(Hospital hospital) {
    // Open external maps application with directions
    // This would typically use url_launcher to open Google Maps, Apple Maps, etc.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening directions to ${hospital.name}')),
    );
  }

  void _showHospitalDetails(Hospital hospital) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(hospital.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Address: ${hospital.address}'),
            Text('Phone: ${hospital.phoneNumber}'),
            if (hospital.specialties.isNotEmpty)
              Text('Specialties: ${hospital.specialties.join(", ")}'),
            Text('Available Beds: ${hospital.availableBeds}'),
            Text('Status: ${hospital.status.displayName}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(S.of(context).close),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _callHospital(hospital.phoneNumber);
            },
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  void _callHospital(String phoneNumber) {
    // Use url_launcher to initiate phone call
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calling $phoneNumber')),
    );
  }

  void _showMedicalInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Medical Information'),
        content: const Text(
          'Please provide details about your medical condition, allergies, and current medications.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
