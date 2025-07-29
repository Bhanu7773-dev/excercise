import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AvatarProvider extends ChangeNotifier {
  File? _avatarFile;
  String? _userName;

  File? get avatarFile => _avatarFile;
  String? get userName => _userName;

  void setAvatar(File file) {
    _avatarFile = file;
    notifyListeners();
  }

  void removeAvatar() {
    _avatarFile = null;
    notifyListeners();
  }

  // Set and persist user name
  Future<void> setUserName(String name) async {
    _userName = name;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
  }

  // Load user name from SharedPreferences
  Future<void> loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('user_name');
    notifyListeners();
  }

  // Optionally: call this on provider init to load username automatically
  Future<void> initialize() async {
    await loadUserName();
  }
}
