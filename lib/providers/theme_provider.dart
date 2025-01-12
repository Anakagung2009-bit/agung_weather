import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  String _temperatureUnit = 'Celsius';
  bool _notificationsEnabled = false;
  Locale _locale = const Locale('en');

  ThemeMode get themeMode => _themeMode;
  String get temperatureUnit => _temperatureUnit;
  bool get notificationsEnabled => _notificationsEnabled;
  Locale get locale => _locale;

  ThemeProvider() {
    _loadPreferences();
  }

  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Load theme mode
    String? themeModeString = prefs.getString('theme_mode');
    if (themeModeString != null) {
      _themeMode = ThemeMode.values.firstWhere(
              (mode) => mode.toString() == themeModeString,
          orElse: () => ThemeMode.system);
    }

    // Load temperature unit
    _temperatureUnit = prefs.getString('temperature_unit') ?? 'Celsius';

    // Load notifications setting
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;

    // Load language
    String? languageCode = prefs.getString('language_code');
    if (languageCode != null) {
      _locale = Locale(languageCode);
    }

    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.toString());
    notifyListeners();
  }

  void setTemperatureUnit(String unit) async {
    _temperatureUnit = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('temperature_unit', unit);
    notifyListeners();
  }

  void setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
    notifyListeners();
  }

  void setLanguage(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    notifyListeners();
  }
}