import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Firebase packages
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_performance/firebase_performance.dart';
// If you have firebase_options.dart (FlutterFire CLI), import it:
// import 'firebase_options.dart';

import 'model/exercise_data.dart';
import 'model/exercise_status_provider.dart';
import 'model/avatar_provider.dart';
import 'utils/theme_provider.dart';
import 'utils/theme_data.dart';
import 'screens/splash.dart';
import 'model/music_bar_provider.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
      // Uncomment below if using FlutterFire CLI:
      // options: DefaultFirebaseOptions.currentPlatform,
      );
  print('Handling a background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
      // Uncomment below if using FlutterFire CLI:
      // options: DefaultFirebaseOptions.currentPlatform,
      );

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(ExerciseAdapter());
  await Hive.openBox<Exercise>('completed_exercises');

  // Crashlytics: record uncaught Flutter errors
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  // Cloud Messaging: set up background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Optionally request notification permissions (for iOS/web)
  await FirebaseMessaging.instance.requestPermission();

  // Performance: enable (optional, enabled by default)
  await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);

  // UI overlays
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final provider = ExerciseStatusProvider();
            provider.init();
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => AvatarProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MusicBarProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Exercise Tracker',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      home:
          const SplashScreen(), // This will show splash, then login, then home
      debugShowCheckedModeBanner: false,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
      ],
    );
  }
}
