import 'package:flutter/material.dart';

class AppConstants {
  // Nama Aplikasi
  static const String appName = 'Agung Weather';

  // Versi Aplikasi
  static const String appVersion = '1.0.0';

  // Deskripsi Singkat Aplikasi
  static const String appDescription = 'Your personal weather companion';

  // Warna Utama Aplikasi (menggunakan konstanta warna)
  static const int _primaryColorValue = 0xFF2196F3;
  static const int _accentColorValue = 0xFF03A9F4;

  static const Color primaryColor = Color(_primaryColorValue);
  static const Color accentColor = Color(_accentColorValue);

  // URL atau konfigurasi lain
  static const String weatherApiBaseUrl = 'https://api.openweathermap.org/data/2.5';

  // Kunci API (sebaiknya disimpan dengan aman)
  static const String weatherApiKey = 'your_api_key_here';

  // Pengaturan Default
  static const String defaultTemperatureUnit = 'Celsius';
  static const bool defaultNotificationSetting = true;

  // Metadata Pengembang
  static const String developerName = 'Agung';
  static const String developerEmail = 'agung@example.com';
}