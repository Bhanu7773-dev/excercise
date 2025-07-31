import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'model/exercise_data.dart';
import 'model/exercise_status_provider.dart';
import 'model/avatar_provider.dart';
import 'utils/theme_provider.dart';
import 'utils/theme_data.dart';
import 'screens/splash.dart';
import 'model/music_bar_provider.dart'; // <-- import your provider here

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ExerciseAdapter());
  await Hive.openBox<Exercise>('completed_exercises');

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
        ChangeNotifierProvider(
            create: (_) => MusicBarProvider()), // <-- Add this!
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to the ThemeProvider for changes
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Exercise Tracker',
      // Use the themes from your theme_data.dart file
      theme: lightTheme,
      darkTheme: darkTheme,
      // Let the ThemeProvider control which theme is active
      themeMode: themeProvider.themeMode,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
