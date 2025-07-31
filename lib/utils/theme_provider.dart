import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the theme state of the application.
///
/// Use this provider to get the current [ThemeMode] and to update it.
/// The selected theme is persisted across app restarts using SharedPreferences.
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  /// Initializes the provider by loading the saved theme preference.
  ThemeProvider() {
    _loadThemeMode();
  }

  /// Loads the theme mode from local storage.
  /// Defaults to [ThemeMode.system] if no preference is found.
  void _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    // Get the saved theme index, defaulting to 0 (system).
    final themeIndex = prefs.getInt('themeMode') ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    notifyListeners();
  }

  /// Updates the application's theme mode and persists the change.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    // Save the index of the selected ThemeMode enum.
    await prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }
}
