import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'theme.dart';

class ThemeProvider extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  ThemeData get currentTheme => _isDarkMode ? AppTheme.escuro : AppTheme.claro;

  Future<void> _loadTheme() async {
    final saved = await _storage.read(key: "darkMode");
    _isDarkMode = saved != "false";
    notifyListeners();
  }

  Future<void> toggleTheme(bool value) async {
    _isDarkMode = value;
    await _storage.write(key: "darkMode", value: value.toString());
    notifyListeners();
  }
}
