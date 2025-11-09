import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
  static FirebaseService? _instance;
  FirebaseMessaging? _messaging;

  FirebaseService._();

  factory FirebaseService() {
    _instance ??= FirebaseService._();
    return _instance!;
  }

  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  Future<void> initializeMessaging() async {
    _messaging = FirebaseMessaging.instance;

    // Request permission for iOS
    await _requestPermission();

    // Get FCM token
    final token = await _messaging?.getToken();
    if (token != null) {
      // Store token for push notifications
      await _storeToken(token);
    }

    // Handle token refresh
    _messaging?.onTokenRefresh.listen(_storeToken);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging?.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings?.authorizationStatus == AuthorizationStatus.authorized) {
      // Permission granted
    } else if (settings?.authorizationStatus == AuthorizationStatus.provisional) {
      // Provisional permission granted
    } else {
      // Permission denied
    }
  }

  Future<void> _storeToken(String token) async {
    // Store the token in secure storage or send to backend
    // This would typically be sent to your backend to associate with the user
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Handle foreground messages
    // This could trigger local notifications or update UI
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    // Handle background messages
    // This is called when the app is in background or terminated
  }

  Future<String?> getToken() async {
    return await _messaging?.getToken();
  }

  Future<void> deleteToken() async {
    await _messaging?.deleteToken();
  }

  Stream<String> get onTokenRefresh {
    return _messaging?.onTokenRefresh ?? const Stream.empty();
  }

  Stream<RemoteMessage> get onMessage {
    return FirebaseMessaging.onMessage;
  }

  Stream<RemoteMessage> get onMessageOpenedApp {
    return FirebaseMessaging.onMessageOpenedApp;
  }

  Future<RemoteMessage?> getInitialMessage() async {
    return await FirebaseMessaging.instance.getInitialMessage();
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging?.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging?.unsubscribeFromTopic(topic);
  }

  Future<void> setForegroundNotificationPresentationOptions({
    bool alert = true,
    bool badge = true,
    bool sound = true,
  }) async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: alert,
      badge: badge,
      sound: sound,
    );
  }
}