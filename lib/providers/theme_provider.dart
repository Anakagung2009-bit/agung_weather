import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_color/dynamic_color.dart';
import '../theme/app_theme.dart';

class ThemeProvider with ChangeNotifier {
  // Variabel privat untuk menyimpan pengaturan
  ThemeMode _themeMode = ThemeMode.system;
  String _temperatureUnit = 'Celsius';
  bool _notificationsEnabled = false;
  Locale _locale = const Locale('en');
  bool _isMaterialYouEnabled = true;

  // Getter untuk semua properti
  ThemeMode get themeMode => _themeMode;
  String get temperatureUnit => _temperatureUnit;
  bool get notificationsEnabled => _notificationsEnabled;
  Locale get locale => _locale;
  bool get isMaterialYouEnabled => _isMaterialYouEnabled;

  // Konstruktor dengan inisialisasi preferensi
  ThemeProvider() {
    _loadPreferences();
  }

  // Method untuk memuat preferensi dari SharedPreferences
  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Load theme mode
    String? themeModeString = prefs.getString('theme_mode');
    if (themeModeString != null) {
      _themeMode = ThemeMode.values.firstWhere(
              (mode) => mode.toString() == themeModeString,
          orElse: () => ThemeMode.system
      );
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

    // Load Material You setting
    _isMaterialYouEnabled = prefs.getBool('material_you_enabled') ?? false;

    // Notify listeners setelah memuat preferensi
    notifyListeners();
  }

  // Method untuk menghasilkan tema berdasarkan brightness
  ThemeData getTheme(Brightness brightness, ColorScheme? dynamicColorScheme) {
    if (_isMaterialYouEnabled && dynamicColorScheme != null) {
      return ThemeData(
        useMaterial3: true,
        colorScheme: dynamicColorScheme,
        textTheme: AppTheme.productSansTextTheme,
        fontFamily: 'ProductSans',
        cardTheme: CardTheme(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        // Tambahkan konfigurasi tambahan untuk membuat tema lebih dinamis
        appBarTheme: AppBarTheme(
          backgroundColor: dynamicColorScheme.surface,
          foregroundColor: dynamicColorScheme.onSurface,
        ),
        scaffoldBackgroundColor: dynamicColorScheme.background,
      );
    } else {
      // Tema default dengan seed color tetap
      return brightness == Brightness.light
          ? AppTheme.lightTheme
          : AppTheme.darkTheme;
    }
  }

  // Method untuk mengatur tema
  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.toString());
    notifyListeners();
  }

  // Method untuk mengatur unit suhu
  void setTemperatureUnit(String unit) async {
    _temperatureUnit = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('temperature_unit', unit);
    notifyListeners();
  }

  // Method untuk mengatur notifikasi
  void setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
    notifyListeners();
  }

  // Method untuk mengatur bahasa
  void setLanguage(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    notifyListeners();
  }

  // Method untuk mengatur Material You
  Future<void> setMaterialYouEnabled(bool enabled) async {
    _isMaterialYouEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('material_you_enabled', enabled);
    notifyListeners(); // Memicu rebuild dengan warna baru
  }


  // Method utilitas untuk konversi suhu
  double convertTemperature(double temperature) {
    if (_temperatureUnit == 'Fahrenheit') {
      // Konversi Celsius ke Fahrenheit
      return (temperature * 9 / 5) + 32;
    }
    return temperature;
  }

  // Method untuk mendapatkan simbol unit suhu
  String getTemperatureUnitSymbol() {
    return _temperatureUnit == 'Celsius' ? '°C' : '°F';
  }
}