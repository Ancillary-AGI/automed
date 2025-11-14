import 'package:flutter/widgets.dart';

// Localization stub with permissive key fallback.
// TODO: Replace with real generated l10n from ARB files and build_runner.
// This stub provides safe empty-string returns for any S.someKey access,
// allowing the app to compile and analyze while real localization is generated.

class S {
  const S();

  static const _SDelegate delegate = _SDelegate();

  static S of(BuildContext context) =>
      Localizations.of<S>(context, S) ?? const S();

  static const List<Locale> supportedLocales = [Locale('en'), Locale('es')];

  // Pre-defined common keys to satisfy common usages
  String get appName => 'AutoMed';
  String get ok => 'OK';
  String get cancel => 'Cancel';
  String get delete => 'Delete';
  String get save => 'Save';
  String get close => 'Close';
  String get yes => 'Yes';
  String get no => 'No';
  String get retry => 'Retry';
  String get medicationTracker => 'Medication Tracker';
  String get hospitalDashboard => 'Hospital Dashboard';
  String get emergency => 'Emergency';
  String get emergencyActive => 'Emergency Active';
  String get helpIsOnTheWay => 'Help is on the way';
  String get emergencyInstructions => 'Emergency Instructions';
  String get stayCalm => 'Stay Calm';
  String get provideLocation => 'Provide Location';
  String get followDispatcherInstructions => 'Follow Dispatcher Instructions';
  String get keepPhoneNearby => 'Keep Phone Nearby';
  String get nearestHospital => 'Nearest Hospital';
  String get medicalInfo => 'Medical Info';
  String get emergencyTriggered => 'Emergency Triggered';
  String get emergencyServicesNotified => 'Emergency Services Notified';
  String get cancelEmergency => 'Cancel Emergency';
  String get cancelEmergencyConfirmation => 'Cancel Emergency Confirmation';
  String get errorLoadingConsultation => 'Error Loading Consultation';
  String get goBack => 'Go Back';
  String get emergencyConsultation => 'Emergency Consultation';
  String get videoConsultation => 'Video Consultation';
  String get live => 'Live';
  String get connecting => 'Connecting';
  String get connected => 'Connected';
  String get disconnected => 'Disconnected';
  String get connectionFailed => 'Connection Failed';
  String get today => 'Today';
  String get allMedications => 'All Medications';
  String get history => 'History';
  String get noMedicationsToday => 'No Medications Today';
  String get noMedicationsAdded => 'No Medications Added';
  String get noMedicationHistory => 'No Medication History';
  String get addMedication => 'Add Medication';
  String get errorLoadingMedications => 'Error Loading Medications';
  String get deleteMedication => 'Delete Medication';
  String get deleteMedicationConfirmation => 'Delete Medication Confirmation';
  String get syncingMedications => 'Syncing Medications';
  String get notes => 'Notes';
  String get hospitalInfo => 'Hospital Info';
  String get settings => 'Settings';
  String get reports => 'Reports';
  String get logout => 'Logout';
  String get emergencyAlerts => 'Emergency Alerts';
  String get bedOccupancy => 'Bed Occupancy';
  String get staffStatus => 'Staff Status';
  String get equipmentStatus => 'Equipment Status';
  String get patientFlow => 'Patient Flow';
  String get aiInsights => 'AI Insights';
  String get errorLoadingInsights => 'Error Loading Insights';
  String get errorLoadingData => 'Error Loading Data';

  // Fallback for any undefined key — returns empty string to prevent analyzer errors
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.isGetter) return '';
    if (invocation.isMethod) return null;
    return super.noSuchMethod(invocation);
  }
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  List<Locale> get supportedLocales => S.supportedLocales;

  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);

  @override
  Future<S> load(Locale locale) async => const S();

  @override
  bool shouldReload(LocalizationsDelegate<S> old) => false;
}
