// Firebase Service Helper - Manages Firebase services for FIT-X app
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();

  FirebaseService._();

  // Firebase service instances
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Analytics Methods
  Future<void> logEvent(String eventName,
      {Map<String, Object>? parameters}) async {
    await _analytics.logEvent(name: eventName, parameters: parameters);
  }

  Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  // Log custom events for fitness app
  Future<void> logWorkoutStarted(String workoutType) async {
    await logEvent('workout_started',
        parameters: {'workout_type': workoutType});
  }

  Future<void> logWorkoutCompleted(String workoutType, int duration) async {
    await logEvent('workout_completed', parameters: {
      'workout_type': workoutType,
      'duration_minutes': duration,
    });
  }

  Future<void> logExerciseCompleted(String exerciseName) async {
    await logEvent('exercise_completed',
        parameters: {'exercise_name': exerciseName});
  }

  // Crashlytics Methods
  Future<void> recordError(dynamic exception, StackTrace? stackTrace,
      {String? reason}) async {
    await _crashlytics.recordError(exception, stackTrace, reason: reason);
  }

  Future<void> log(String message) async {
    await _crashlytics.log(message);
  }

  Future<void> setCustomKey(String key, Object value) async {
    await _crashlytics.setCustomKey(key, value);
  }

  Future<void> setUserIdentifier(String identifier) async {
    await _crashlytics.setUserIdentifier(identifier);
  }

  // Messaging Methods
  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  // Subscribe to fitness-related topics
  Future<void> subscribeToFitnessTopics() async {
    await subscribeToTopic('fitness_tips');
    await subscribeToTopic('workout_reminders');
    await subscribeToTopic('app_updates');
  }

  // Set up message listeners
  void setupMessageListeners() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        // TODO: Show local notification or update UI
      }
    });

    // Handle message taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      // TODO: Navigate to specific screen based on message data
    });
  }
}
