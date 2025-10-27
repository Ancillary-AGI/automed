# 🔥 Firebase Setup Guide - Automed Healthcare Platform

## 📋 Overview

The Automed platform uses Firebase for comprehensive backend services including push notifications, analytics, crash reporting, performance monitoring, and real-time data synchronization. This guide covers the complete Firebase setup and configuration.

## 🚀 Firebase Services Integrated

### ✅ **Core Services**
- **Firebase Core** - Foundation for all Firebase services
- **Firebase Messaging** - Push notifications for healthcare alerts
- **Firebase Crashlytics** - Crash reporting and error tracking
- **Firebase Analytics** - User behavior and app performance analytics
- **Firebase Performance** - App performance monitoring
- **Firebase Remote Config** - Dynamic configuration management

### ✅ **Authentication & Data**
- **Firebase Auth** - User authentication and management
- **Cloud Firestore** - Real-time database for healthcare data
- **Firebase Storage** - File storage for medical documents and images

## 🛠️ Setup Instructions

### 1. **Create Firebase Project**

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name: `automed-healthcare`
4. Enable Google Analytics (recommended)
5. Choose or create Analytics account

### 2. **Add Apps to Firebase Project**

#### **Android App**
1. Click "Add app" → Android
2. Package name: `com.automed.app`
3. App nickname: `Automed Android`
4. Download `google-services.json`
5. Place in `android/app/` directory

#### **iOS App**
1. Click "Add app" → iOS
2. Bundle ID: `com.automed.app`
3. App nickname: `Automed iOS`
4. Download `GoogleService-Info.plist`
5. Place in `ios/Runner/` directory

#### **Web App**
1. Click "Add app" → Web
2. App nickname: `Automed Web`
3. Copy configuration object
4. Update `firebase_options.dart` with web config

### 3. **Configure Firebase Services**

#### **Firebase Messaging (Push Notifications)**
```bash
# Enable Firebase Messaging API
1. Go to Firebase Console → Project Settings
2. Click "Cloud Messaging" tab
3. Note the Server Key for backend integration
```

#### **Firebase Crashlytics**
```bash
# Enable Crashlytics
1. Go to Firebase Console → Crashlytics
2. Click "Enable Crashlytics"
3. Follow setup instructions
```

#### **Firebase Analytics**
```bash
# Analytics is enabled by default
# Configure custom events in Firebase Console → Analytics
```

#### **Firebase Performance**
```bash
# Enable Performance Monitoring
1. Go to Firebase Console → Performance
2. Click "Get started"
3. Performance data will appear after app usage
```

#### **Firebase Remote Config**
```bash
# Set up Remote Config parameters
1. Go to Firebase Console → Remote Config
2. Add parameters:
   - feature_ai_assistant: true
   - feature_telemedicine: true
   - feature_offline_mode: true
   - max_offline_days: 7
   - emergency_contact: "+1-800-EMERGENCY"
   - api_timeout_seconds: 30
   - cache_duration_hours: 24
```

#### **Cloud Firestore**
```bash
# Set up Firestore database
1. Go to Firebase Console → Firestore Database
2. Click "Create database"
3. Choose "Start in production mode"
4. Select location (choose closest to users)
```

#### **Firebase Storage**
```bash
# Set up Storage
1. Go to Firebase Console → Storage
2. Click "Get started"
3. Choose security rules (start in production mode)
4. Select location
```

## 🔧 Configuration Files

### **firebase_options.dart**
Update the configuration with your actual Firebase project values:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ANDROID_API_KEY',
  appId: 'YOUR_ANDROID_APP_ID',
  messagingSenderId: 'YOUR_SENDER_ID',
  projectId: 'automed-healthcare',
  storageBucket: 'automed-healthcare.appspot.com',
);

static const FirebaseOptions ios = FirebaseOptions(
  apiKey: 'YOUR_IOS_API_KEY',
  appId: 'YOUR_IOS_APP_ID',
  messagingSenderId: 'YOUR_SENDER_ID',
  projectId: 'automed-healthcare',
  storageBucket: 'automed-healthcare.appspot.com',
  iosBundleId: 'com.automed.app',
);

static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_WEB_API_KEY',
  appId: 'YOUR_WEB_APP_ID',
  messagingSenderId: 'YOUR_SENDER_ID',
  projectId: 'automed-healthcare',
  authDomain: 'automed-healthcare.firebaseapp.com',
  storageBucket: 'automed-healthcare.appspot.com',
  measurementId: 'YOUR_MEASUREMENT_ID',
);
```

### **Android Configuration**

#### **android/app/build.gradle**
```gradle
dependencies {
    implementation 'com.google.firebase:firebase-analytics'
    implementation 'com.google.firebase:firebase-crashlytics'
    implementation 'com.google.firebase:firebase-messaging'
}

apply plugin: 'com.google.gms.google-services'
apply plugin: 'com.google.firebase.crashlytics'
```

#### **android/build.gradle**
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
        classpath 'com.google.firebase:firebase-crashlytics-gradle:2.9.9'
    }
}
```

### **iOS Configuration**

#### **ios/Runner/Info.plist**
```xml
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
<key>FirebaseAutomaticScreenReportingEnabled</key>
<true/>
```

#### **ios/Podfile**
```ruby
pod 'Firebase/Analytics'
pod 'Firebase/Crashlytics'
pod 'Firebase/Messaging'
```

## 📱 Healthcare-Specific Notification Topics

The app automatically subscribes to healthcare-specific notification topics:

### **Patient Notifications**
- `patient_{patientId}` - Individual patient alerts
- `healthcare_alerts` - General healthcare alerts
- `medication_reminders` - Medication reminders
- `emergency_notifications` - Emergency alerts

### **Hospital Notifications**
- `hospital_{hospitalId}` - Hospital-specific alerts
- `staff_notifications` - Staff communications
- `system_alerts` - System status alerts

### **Notification Types**
```dart
enum HealthcareNotificationType {
  criticalAlert,      // Critical patient alerts
  medicationReminder, // Medication reminders
  appointmentReminder,// Appointment reminders
  vitalSignsAlert,    // Vital signs alerts
  emergencyAlert,     // Emergency situations
  labResults,         // Lab result notifications
  consultationRequest,// Telemedicine requests
}
```

## 🔒 Security Rules

### **Firestore Security Rules**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Healthcare providers can read/write patient data they're assigned to
    match /patients/{patientId} {
      allow read, write: if request.auth != null 
        && (request.auth.token.role == 'healthcare_provider' 
        || request.auth.token.role == 'admin'
        || request.auth.uid == patientId);
    }
    
    // Medical records require healthcare provider access
    match /medical_records/{recordId} {
      allow read, write: if request.auth != null 
        && (request.auth.token.role == 'healthcare_provider' 
        || request.auth.token.role == 'admin');
    }
    
    // Emergency data is readable by all authenticated healthcare providers
    match /emergency_protocols/{protocolId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null 
        && request.auth.token.role == 'admin';
    }
  }
}
```

### **Storage Security Rules**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Medical documents
    match /medical_documents/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null 
        && (request.auth.uid == userId 
        || request.auth.token.role == 'healthcare_provider'
        || request.auth.token.role == 'admin');
    }
    
    // Profile images
    match /profile_images/{userId} {
      allow read, write: if request.auth != null 
        && request.auth.uid == userId;
    }
  }
}
```

## 📊 Analytics Events

### **Healthcare-Specific Events**
```dart
// Critical healthcare events
FirebaseService.instance.logEvent('critical_alert_received', {
  'patient_id': patientId,
  'alert_type': alertType,
  'severity': severity,
});

// Medication events
FirebaseService.instance.logEvent('medication_administered', {
  'patient_id': patientId,
  'medication': medicationName,
  'dosage': dosage,
});

// Consultation events
FirebaseService.instance.logEvent('telemedicine_session_started', {
  'patient_id': patientId,
  'provider_id': providerId,
  'session_type': sessionType,
});
```

## 🚨 Error Handling & Monitoring

### **Crashlytics Integration**
```dart
// Record custom errors
FirebaseService.instance.recordError(
  exception, 
  stackTrace, 
  fatal: true
);

// Set custom keys for debugging
FirebaseCrashlytics.instance.setCustomKey('patient_id', patientId);
FirebaseCrashlytics.instance.setCustomKey('feature', 'telemedicine');
```

### **Performance Monitoring**
```dart
// Track custom traces
final trace = FirebaseService.instance.startTrace('patient_data_load');
// ... perform operation
await trace.stop();

// Track network requests automatically
// HTTP requests are tracked automatically
```

## 🔄 Real-Time Data Sync

### **Firestore Real-Time Listeners**
```dart
// Listen to patient data changes
FirebaseFirestore.instance
  .collection('patients')
  .doc(patientId)
  .snapshots()
  .listen((snapshot) {
    if (snapshot.exists) {
      final patientData = snapshot.data();
      // Update local state
    }
  });

// Listen to vital signs updates
FirebaseFirestore.instance
  .collection('vital_signs')
  .where('patient_id', isEqualTo: patientId)
  .orderBy('timestamp', descending: true)
  .limit(10)
  .snapshots()
  .listen((snapshot) {
    final vitalSigns = snapshot.docs.map((doc) => doc.data()).toList();
    // Update real-time monitoring
  });
```

## 🧪 Testing Firebase Integration

### **Test Push Notifications**
1. Go to Firebase Console → Cloud Messaging
2. Click "Send your first message"
3. Enter notification details
4. Select target (app or topic)
5. Send test message

### **Test Crashlytics**
```dart
// Force a crash for testing
FirebaseCrashlytics.instance.crash();

// Test non-fatal error
FirebaseCrashlytics.instance.recordError(
  'Test error',
  StackTrace.current,
  fatal: false,
);
```

### **Test Analytics**
```dart
// Test custom event
FirebaseAnalytics.instance.logEvent(
  name: 'test_event',
  parameters: {
    'test_parameter': 'test_value',
  },
);
```

## 🚀 Production Deployment

### **Environment Configuration**
- **Development**: Use test Firebase project
- **Staging**: Use staging Firebase project  
- **Production**: Use production Firebase project

### **Performance Optimization**
- Enable Firestore offline persistence
- Use Firebase Performance monitoring
- Implement proper error handling
- Set up automated alerts for critical issues

### **Monitoring & Alerts**
- Set up Crashlytics alerts for new crashes
- Monitor Performance metrics
- Track Analytics conversion events
- Set up Cloud Monitoring alerts

## 📞 Support & Resources

- **Firebase Documentation**: https://firebase.google.com/docs
- **FlutterFire Documentation**: https://firebase.flutter.dev/
- **Firebase Console**: https://console.firebase.google.com/
- **Firebase Status**: https://status.firebase.google.com/

---

## ✅ **Firebase Integration Complete!**

The Automed platform now has comprehensive Firebase integration with:
- ✅ Push notifications for healthcare alerts
- ✅ Real-time crash reporting and monitoring
- ✅ Advanced analytics for healthcare insights
- ✅ Performance monitoring for optimal user experience
- ✅ Remote configuration for feature management
- ✅ Secure authentication and data storage
- ✅ Real-time data synchronization

**Your healthcare platform is now powered by Firebase! 🔥🏥**