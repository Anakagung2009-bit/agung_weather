import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

import '../services/auth_service.dart';
import '../providers/weather_provider.dart';
import '../providers/theme_provider.dart';
import '../constants/app_constants.dart';
import '../utils/localization.dart';
import '../screens/login_screen.dart'; // Pastikan import login screen

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();

  // Method untuk mengecek dukungan Material You
  Future<bool> _isMaterialYouSupported() async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

      // Material You tersedia di Android 12 (API level 31) ke atas
      return androidInfo.version.sdkInt >= 31;
    }

    // Untuk platform lain, return false
    return false;
  }

  // Method untuk logout
  void _logout(BuildContext context) async {
    try {
      await _authService.signOut();
      Provider.of<WeatherProvider>(context, listen: false).clearSavedLocations();

      // Navigasi ke login screen dan hapus semua route sebelumnya
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (Route<dynamic> route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.translate('logout_success')),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.translate('logout_failed')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Method untuk menampilkan dialog bahasa
  void _showLanguageDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.translate('select_language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(context, themeProvider, 'English', Locale('en')),
            _buildLanguageOption(context, themeProvider, 'Indonesia', Locale('id')),
          ],
        ),
      ),
    );
  }

  // Widget untuk opsi bahasa
  Widget _buildLanguageOption(
      BuildContext context,
      ThemeProvider themeProvider,
      String languageName,
      Locale locale
      ) {
    return ListTile(
      title: Text(languageName),
      trailing: Radio<Locale>(
        value: locale,
        groupValue: themeProvider.locale,
        onChanged: (selectedLocale) {
          if (selectedLocale != null) {
            themeProvider.setLanguage(selectedLocale);
            Navigator.of(context).pop();
          }
        },
      ),
      onTap: () {
        themeProvider.setLanguage(locale);
        Navigator.of(context).pop();
      },
    );
  }

  // Method untuk menampilkan dialog unit suhu
  void _showTemperatureUnitDialog(
      BuildContext context,
      ThemeProvider themeProvider
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.translate('select_temperature_unit')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTemperatureUnitOption(context, themeProvider, 'Celsius', 'Celsius'),
            _buildTemperatureUnitOption(context, themeProvider, 'Fahrenheit', 'Fahrenheit'),
          ],
        ),
      ),
    );
  }

  // Widget untuk opsi unit suhu
  Widget _buildTemperatureUnitOption(
      BuildContext context,
      ThemeProvider themeProvider,
      String unitName,
      String unitValue
      ) {
    return ListTile(
      title: Text(unitName),
      trailing: Radio<String>(
        value: unitValue,
        groupValue: themeProvider.temperatureUnit,
        onChanged: (selectedUnit) {
          if (selectedUnit != null) {
            themeProvider.setTemperatureUnit(selectedUnit);
            Navigator.of(context).pop();
          }
        },
      ),
      onTap: () {
        themeProvider.setTemperatureUnit(unitValue);
        Navigator.of(context).pop();
      },
    );
  }

  // Method untuk menampilkan dialog tentang aplikasi
  void _showAboutAppDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: AppConstants.appName,
        applicationVersion: AppConstants.appVersion,
        applicationIcon: FlutterLogo(size: 50),
        children: [
          Text(context.translate('weather_app_info')),
          SizedBox(height: 16),
          Text(context.translate('developed_by')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.translate('settings'),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Bagian Profil Pengguna
          _buildUserProfileSection(context, themeProvider),

          SizedBox(height: 16),

          // Bagian Pengaturan Aplikasi
          _buildAppSettingsSection(context, themeProvider),

          SizedBox(height: 16),

          // Bagian Tentang Aplikasi
          _buildAboutSection(context),
        ],
      ),
    );
  }

  // Widget bagian profil pengguna
  Widget _buildUserProfileSection(BuildContext context, ThemeProvider themeProvider) {
    return StreamBuilder<User?>(
      stream: _authService.user,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        if (snapshot.connectionState == ConnectionState.active) {
          return user != null
              ? _buildLoggedInUserCard(user, colorScheme, textTheme)
              : _buildLoginButton(colorScheme, textTheme);
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  // Card untuk pengguna yang sudah login
  Widget _buildLoggedInUserCard(
      User user,
      ColorScheme colorScheme,
      TextTheme textTheme
      ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(user.photoURL ?? ''),
              radius: 30,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName ?? '',
                    style: textTheme.titleLarge,
                  ),
                  SizedBox(height: 4),
                  Text(
                    user.email ?? '',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }

  // Tombol untuk login jika pengguna belum login
  Widget _buildLoginButton(ColorScheme colorScheme, TextTheme textTheme) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginScreen()));
      },
      child: Text(context.translate('login')),
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        padding: EdgeInsets.symmetric(vertical: 16),
        textStyle: textTheme.labelLarge,
      ),
    );
  }

  // Widget bagian pengaturan aplikasi
  Widget _buildAppSettingsSection(BuildContext context, ThemeProvider themeProvider) {
    return FutureBuilder<bool>(
      future: _isMaterialYouSupported(),
      builder: (context, snapshot) {
        bool isMaterialYouSupported = snapshot.data ?? false;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.translate('app_settings'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                SizedBox(height: 16),
                _buildSettingItem(
                  context,
                  icon: Icons.palette_rounded,
                  title: 'Material You',
                  subtitle: 'Dynamic color from wallpaper',
                  trailing: Switch(
                    value: themeProvider.isMaterialYouEnabled,
                    onChanged: (bool value) {
                      themeProvider.setMaterialYouEnabled(value);
                    },
                  ),
                ),
                _buildSettingItem(
                  context,
                  icon: Icons.dark_mode_rounded,
                  title: context.translate('dark_mode'),
                  trailing: Switch(
                    value: themeProvider.themeMode == ThemeMode.dark,
                    onChanged: (bool value) {
                      themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                    },
                  ),
                ),
                _buildSettingItem(
                  context,
                  icon: Icons.language,
                  title: context.translate('language'),
                  subtitle: themeProvider.locale.languageCode == 'en' ? 'English' : 'Indonesia',
                  onTap: () => _showLanguageDialog(context, themeProvider),
                ),
                _buildSettingItem(
                  context,
                  icon: Icons.thermostat_rounded,
                  title: context.translate('temperature_unit'),
                  subtitle: themeProvider.temperatureUnit,
                  onTap: () => _showTemperatureUnitDialog(context, themeProvider),
                ),
                _buildSettingItem(
                  context,
                  icon: Icons.notifications_rounded,
                  title: context.translate('weather_notifications'),
                  trailing: Switch(
                    value: themeProvider.notificationsEnabled,
                    onChanged: (bool value) {
                      themeProvider.setNotificationsEnabled(value);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget bagian tentang aplikasi
  Widget _buildAboutSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        title: Text(context.translate('about')),
        onTap: () => _showAboutAppDialog(context),
      ),
    );
  }

  // Widget untuk item pengaturan
  Widget _buildSettingItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        String? subtitle,
        Widget? trailing,
        VoidCallback? onTap,
      }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}