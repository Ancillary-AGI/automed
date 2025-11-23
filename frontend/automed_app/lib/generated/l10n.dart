import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_en.dart';
import 'l10n_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Automed'**
  String get appName;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get help;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @accessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get accessibility;

  /// No description provided for @emergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergency;

  /// No description provided for @emergencyConsultation.
  ///
  /// In en, this message translates to:
  /// **'Emergency Consultation'**
  String get emergencyConsultation;

  /// No description provided for @videoConsultation.
  ///
  /// In en, this message translates to:
  /// **'Video Consultation'**
  String get videoConsultation;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get live;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting'**
  String get connecting;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @errorLoadingConsultation.
  ///
  /// In en, this message translates to:
  /// **'Error loading consultation'**
  String get errorLoadingConsultation;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoadingData;

  /// No description provided for @errorLoadingInsights.
  ///
  /// In en, this message translates to:
  /// **'Error loading AI insights'**
  String get errorLoadingInsights;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @hospitalDashboard.
  ///
  /// In en, this message translates to:
  /// **'Hospital Dashboard'**
  String get hospitalDashboard;

  /// No description provided for @patientDashboard.
  ///
  /// In en, this message translates to:
  /// **'Patient Dashboard'**
  String get patientDashboard;

  /// No description provided for @healthMetrics.
  ///
  /// In en, this message translates to:
  /// **'Health Metrics'**
  String get healthMetrics;

  /// No description provided for @healthOverview.
  ///
  /// In en, this message translates to:
  /// **'Health Overview'**
  String get healthOverview;

  /// No description provided for @aiInsights.
  ///
  /// In en, this message translates to:
  /// **'AI Insights'**
  String get aiInsights;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @advancedAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Advanced Analytics'**
  String get advancedAnalytics;

  /// No description provided for @medicationTracker.
  ///
  /// In en, this message translates to:
  /// **'Medication Tracker'**
  String get medicationTracker;

  /// No description provided for @appointmentScheduler.
  ///
  /// In en, this message translates to:
  /// **'Appointment Scheduler'**
  String get appointmentScheduler;

  /// No description provided for @emergencyResponse.
  ///
  /// In en, this message translates to:
  /// **'Emergency Response'**
  String get emergencyResponse;

  /// No description provided for @telemedicine.
  ///
  /// In en, this message translates to:
  /// **'Telemedicine'**
  String get telemedicine;

  /// No description provided for @realTimeMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Real-Time Monitoring'**
  String get realTimeMonitoring;

  /// No description provided for @predictiveAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Predictive Analytics'**
  String get predictiveAnalytics;

  /// No description provided for @smartMedication.
  ///
  /// In en, this message translates to:
  /// **'Smart Medication'**
  String get smartMedication;

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get offlineMode;

  /// No description provided for @multiTenant.
  ///
  /// In en, this message translates to:
  /// **'Multi-Tenant'**
  String get multiTenant;

  /// No description provided for @advancedSecurity.
  ///
  /// In en, this message translates to:
  /// **'Advanced Security'**
  String get advancedSecurity;

  /// No description provided for @kubernetesDeployment.
  ///
  /// In en, this message translates to:
  /// **'Kubernetes Deployment'**
  String get kubernetesDeployment;

  /// No description provided for @ciCdPipeline.
  ///
  /// In en, this message translates to:
  /// **'CI/CD Pipeline'**
  String get ciCdPipeline;

  /// No description provided for @loadTesting.
  ///
  /// In en, this message translates to:
  /// **'Load Testing'**
  String get loadTesting;

  /// No description provided for @documentation.
  ///
  /// In en, this message translates to:
  /// **'Documentation'**
  String get documentation;

  /// No description provided for @apiDocumentation.
  ///
  /// In en, this message translates to:
  /// **'API Documentation'**
  String get apiDocumentation;

  /// No description provided for @userGuide.
  ///
  /// In en, this message translates to:
  /// **'User Guide'**
  String get userGuide;

  /// No description provided for @developerGuide.
  ///
  /// In en, this message translates to:
  /// **'Developer Guide'**
  String get developerGuide;

  /// No description provided for @systemStatus.
  ///
  /// In en, this message translates to:
  /// **'System Status'**
  String get systemStatus;

  /// No description provided for @performanceMetrics.
  ///
  /// In en, this message translates to:
  /// **'Performance Metrics'**
  String get performanceMetrics;

  /// No description provided for @resourceUtilization.
  ///
  /// In en, this message translates to:
  /// **'Resource Utilization'**
  String get resourceUtilization;

  /// No description provided for @bedOccupancy.
  ///
  /// In en, this message translates to:
  /// **'Bed Occupancy'**
  String get bedOccupancy;

  /// No description provided for @staffStatus.
  ///
  /// In en, this message translates to:
  /// **'Staff Status'**
  String get staffStatus;

  /// No description provided for @equipmentStatus.
  ///
  /// In en, this message translates to:
  /// **'Equipment Status'**
  String get equipmentStatus;

  /// No description provided for @patientFlow.
  ///
  /// In en, this message translates to:
  /// **'Patient Flow'**
  String get patientFlow;

  /// No description provided for @emergencyAlerts.
  ///
  /// In en, this message translates to:
  /// **'Emergency Alerts'**
  String get emergencyAlerts;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @upcomingAppointments.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Appointments'**
  String get upcomingAppointments;

  /// No description provided for @medicationReminders.
  ///
  /// In en, this message translates to:
  /// **'Medication Reminders'**
  String get medicationReminders;

  /// No description provided for @vitalSigns.
  ///
  /// In en, this message translates to:
  /// **'Vital Signs'**
  String get vitalSigns;

  /// No description provided for @heartRate.
  ///
  /// In en, this message translates to:
  /// **'Heart Rate'**
  String get heartRate;

  /// No description provided for @bloodPressure.
  ///
  /// In en, this message translates to:
  /// **'Blood Pressure'**
  String get bloodPressure;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @oxygenSaturation.
  ///
  /// In en, this message translates to:
  /// **'Oxygen Saturation'**
  String get oxygenSaturation;

  /// No description provided for @emergencyActive.
  ///
  /// In en, this message translates to:
  /// **'Emergency Active'**
  String get emergencyActive;

  /// No description provided for @helpIsOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'Help is on the way'**
  String get helpIsOnTheWay;

  /// No description provided for @emergencyInstructions.
  ///
  /// In en, this message translates to:
  /// **'Emergency Instructions'**
  String get emergencyInstructions;

  /// No description provided for @stayCalm.
  ///
  /// In en, this message translates to:
  /// **'Stay calm and remain where you are'**
  String get stayCalm;

  /// No description provided for @provideLocation.
  ///
  /// In en, this message translates to:
  /// **'Provide your location to emergency services'**
  String get provideLocation;

  /// No description provided for @followDispatcherInstructions.
  ///
  /// In en, this message translates to:
  /// **'Follow dispatcher instructions'**
  String get followDispatcherInstructions;

  /// No description provided for @keepPhoneNearby.
  ///
  /// In en, this message translates to:
  /// **'Keep your phone nearby'**
  String get keepPhoneNearby;

  /// No description provided for @nearestHospital.
  ///
  /// In en, this message translates to:
  /// **'Nearest Hospital'**
  String get nearestHospital;

  /// No description provided for @medicalInfo.
  ///
  /// In en, this message translates to:
  /// **'Medical Information'**
  String get medicalInfo;

  /// No description provided for @emergencyTriggered.
  ///
  /// In en, this message translates to:
  /// **'Emergency has been triggered'**
  String get emergencyTriggered;

  /// No description provided for @emergencyServicesNotified.
  ///
  /// In en, this message translates to:
  /// **'Emergency services have been notified'**
  String get emergencyServicesNotified;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancelEmergency.
  ///
  /// In en, this message translates to:
  /// **'Cancel Emergency'**
  String get cancelEmergency;

  /// No description provided for @cancelEmergencyConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel the emergency?'**
  String get cancelEmergencyConfirmation;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @allMedications.
  ///
  /// In en, this message translates to:
  /// **'All Medications'**
  String get allMedications;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @noMedicationsToday.
  ///
  /// In en, this message translates to:
  /// **'No medications scheduled for today'**
  String get noMedicationsToday;

  /// No description provided for @noMedicationsAdded.
  ///
  /// In en, this message translates to:
  /// **'No medications have been added yet'**
  String get noMedicationsAdded;

  /// No description provided for @noMedicationHistory.
  ///
  /// In en, this message translates to:
  /// **'No medication history available'**
  String get noMedicationHistory;

  /// No description provided for @addMedication.
  ///
  /// In en, this message translates to:
  /// **'Add Medication'**
  String get addMedication;

  /// No description provided for @errorLoadingMedications.
  ///
  /// In en, this message translates to:
  /// **'Error loading medications'**
  String get errorLoadingMedications;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @syncingMedications.
  ///
  /// In en, this message translates to:
  /// **'Syncing medications...'**
  String get syncingMedications;

  /// No description provided for @deleteMedication.
  ///
  /// In en, this message translates to:
  /// **'Delete Medication'**
  String get deleteMedication;

  /// No description provided for @deleteMedicationConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this medication?'**
  String get deleteMedicationConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
    case 'es':
      return SEs();
  }

  throw FlutterError(
      'S.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
