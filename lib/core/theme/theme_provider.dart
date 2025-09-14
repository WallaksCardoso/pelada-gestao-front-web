import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'theme.dart'; // onde estão seus AppTheme.lightTheme e AppTheme.darkTheme

class ThemeProvider extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  ThemeData get currentTheme =>
      _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

  Future<void> _loadTheme() async {
    final saved = await _storage.read(key: "darkMode");
    _isDarkMode = saved == "true";
    notifyListeners();
  }

  Future<void> toggleTheme(bool value) async {
    _isDarkMode = value;
    await _storage.write(key: "darkMode", value: value.toString());
    notifyListeners();
  }
}
