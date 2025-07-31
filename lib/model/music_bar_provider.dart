import 'package:flutter/material.dart';

class MusicBarProvider extends ChangeNotifier {
  /// Whether to use the glass UI music player (true) or the normal one (false).
  bool _useGlassPlayer = false;

  bool get useGlassPlayer => _useGlassPlayer;

  /// Set the music player UI. Call this from your toggle switch.
  void setUseGlassPlayer(bool value) {
    if (_useGlassPlayer != value) {
      _useGlassPlayer = value;
      notifyListeners();
    }
  }

  /// Optionally, provide a simple toggle method.
  void togglePlayer() {
    _useGlassPlayer = !_useGlassPlayer;
    notifyListeners();
  }
}
