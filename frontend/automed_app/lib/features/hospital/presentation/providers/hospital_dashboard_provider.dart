import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:automed_app/core/models/hospital_models.dart';
import 'package:automed_app/core/di/injection.dart';

// Hospital dashboard provider
final hospitalDashboardProvider =
    FutureProvider<HospitalDashboard>((ref) async {
  final apiService = ref.watch(apiServiceProvider);

  // For now, assume hospital ID is 'current' - in real app this would come from auth
  const hospitalId = 'current';

  try {
    // Fetch capacity data
    final capacityData =
        await apiService.get('/hospitals/$hospitalId/capacity');
    final capacity = HospitalCapacity.fromJson(capacityData);

    // Fetch staff data
    final staffData = await apiService.get('/hospitals/$hospitalId/staff');
    final staffList =
        (staffData as List).map((json) => Staff.fromJson(json)).toList();
    final staffOnDuty =
        staffList.where((staff) => staff.status == StaffStatus.active).length;

    // Fetch equipment data
    final equipmentData =
        await apiService.get('/hospitals/$hospitalId/equipment');
    final equipmentList = (equipmentData as List)
        .map((json) => Equipment.fromJson(json))
        .toList();
    final equipmentOperational = equipmentList
        .where((equipment) => equipment.status == EquipmentStatus.operational)
        .length;

    // Fetch hospital info
    final hospitalData = await apiService.get('/hospitals/$hospitalId');
    final hospital = Hospital.fromJson(hospitalData);

    // Mock alerts and AI insights for now
    final activeAlerts = <String>[];
    final aiInsights = [
      'Patient flow optimization recommended for Emergency Department',
      'Equipment maintenance due for 3 devices in ICU',
      'Staff utilization at 85% - consider additional shifts',
      'Inventory levels low for critical medications'
    ];

    return HospitalDashboard(
      hospitalId: hospitalId,
      hospitalName: hospital.name,
      totalBeds: capacity.totalBeds,
      occupiedBeds: capacity.totalBeds - capacity.availableBeds,
      availableBeds: capacity.availableBeds,
      occupancyRate: capacity.occupancyRate,
      staffOnDuty: staffOnDuty,
      totalStaff: staffList.length,
      equipmentOperational: equipmentOperational,
      totalEquipment: equipmentList.length,
      activeAlerts: activeAlerts,
      aiInsights: aiInsights,
      lastUpdated: DateTime.now(),
    );
  } catch (e) {
    // Return mock data if API fails
    return HospitalDashboard(
      hospitalId: hospitalId,
      hospitalName: 'General Hospital',
      totalBeds: 100,
      occupiedBeds: 75,
      availableBeds: 25,
      occupancyRate: 75.0,
      staffOnDuty: 45,
      totalStaff: 50,
      equipmentOperational: 85,
      totalEquipment: 100,
      activeAlerts: ['Emergency alert: ICU capacity at 90%'],
      aiInsights: [
        'Optimize patient flow in Emergency Department',
        'Schedule maintenance for radiology equipment',
        'Consider additional nursing staff for night shift'
      ],
      lastUpdated: DateTime.now(),
    );
  }
});
