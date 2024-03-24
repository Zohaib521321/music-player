import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkTheme = false; // Initial theme
  IconData _themeIcon = Icons.light_mode; // Initial theme icon

  bool get isDarkTheme => _isDarkTheme;
  IconData get themeIcon => _themeIcon;

  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    _themeIcon = _isDarkTheme ? Icons.dark_mode : Icons.light_mode;
    notifyListeners();
  }

  ThemeData getThemeData() {
    return _isDarkTheme ? ThemeData.dark() : ThemeData.light();
  }
}
