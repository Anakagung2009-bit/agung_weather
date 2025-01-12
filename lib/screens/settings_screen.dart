import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../providers/weather_provider.dart';
import '../providers/theme_provider.dart';
import '../constants/app_constants.dart';
import '../utils/localization.dart'; // Tambahkan import ini

class SettingsScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.translate('settings'), // Gunakan translate
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, child) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              // User Profile Section
              _buildProfileSection(context, themeProvider),

              const SizedBox(height: 16),

              // Settings Sections
              _buildSettingsSection(context, themeProvider),

              const SizedBox(height: 16),

              // About and Support
              _buildAboutSection(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, ThemeProvider themeProvider) {
    return StreamBuilder<User?>(
      stream: _authService.user,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        if (snapshot.connectionState == ConnectionState.active) {
          return user != null
              ? FilledCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: user.photoURL != null
                        ? NetworkImage(user.photoURL!)
                        : null,
                    child: user.photoURL == null
                        ? Icon(
                      Icons.person,
                      size: 40,
                      color: colorScheme.primary,
                    )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName ?? 'User',
                          style: textTheme.titleMedium,
                        ),
                        Text(
                          user.email ?? '',
                          style: textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.logout, color: colorScheme.error),
                    onPressed: () => _logout(context),
                  ),
                ],
              ),
            ),
          )
              : ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pushNamed('/login'),
            icon: Icon(Icons.login, color: colorScheme.onPrimary),
            label: Text(
              context.translate('login'), // Gunakan translate
              style: TextStyle(color: colorScheme.onPrimary),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildSettingsSection(BuildContext context, ThemeProvider themeProvider) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return FilledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              context.translate('app_settings'), // Gunakan translate
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildSettingItem(
            context,
            icon: Icons.dark_mode_rounded,
            title: context.translate('dark_mode'), // Gunakan translate
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
            title: context.translate('language'), // Gunakan translate
            subtitle: themeProvider.locale.languageCode == 'en' ? 'English' : 'Indonesia',
            onTap: () => _showLanguageDialog(context, themeProvider),
          ),
          _buildSettingItem(
            context,
            icon: Icons.thermostat_rounded,
            title: context.translate('temperature_unit'), // Gunakan translate
            subtitle: themeProvider.temperatureUnit,
            onTap: () => _showTemperatureUnitDialog(context, themeProvider),
          ),
          _buildSettingItem(
            context,
            icon: Icons.notifications_rounded,
            title: context.translate('weather_notifications'), // Gunakan translate
            trailing: Switch(
              value: themeProvider.notificationsEnabled,
              onChanged: (bool value) {
                themeProvider.setNotificationsEnabled(value);
              },
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildAboutSection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return FilledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'About',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.info_outline_rounded),
            title: Text(context.translate('about') + ' ${AppConstants.appName}'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) async {
    try {
      await _authService.signOut();
      Provider.of<WeatherProvider>(context, listen: false).clearSavedLocations();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.translate('logout_success'))),
      );
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.translate('logout_failed')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showLanguageDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.translate('select_language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('English'),
              onTap: () {
                themeProvider.setLanguage(Locale('en'));
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text('Indonesia'),
              onTap: () {
                themeProvider.setLanguage(Locale('id'));
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }


  void _showTemperatureUnitDialog(
      BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Temperature Unit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: Text(' Celsius'),
              value: 'Celsius',
              groupValue: themeProvider.temperatureUnit,
              onChanged: (value) {
                themeProvider.setTemperatureUnit(value.toString());
                Navigator.of(context).pop();
              },
            ),
            RadioListTile(
              title: Text('Fahrenheit'),
              value: 'Fahrenheit',
              groupValue: themeProvider.temperatureUnit,
              onChanged: (value) {
                themeProvider.setTemperatureUnit(value.toString());
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Agung Weather',
      applicationVersion: '1.0.0',
      applicationIcon: FlutterLogo(),
      children: [
        Text(context.translate('weather_app_info')),
        Text(context.translate('developed_by')),
      ],
    );
  }
}

// Tambahkan custom widget untuk FilledCard
class FilledCard extends StatelessWidget {
  final Widget child;

  const FilledCard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}