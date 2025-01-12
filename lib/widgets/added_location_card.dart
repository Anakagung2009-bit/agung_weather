import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../services/auth_service.dart';
import '../screens/weather_details_screen.dart';
import '../utils/localization.dart'; // Tambahkan import ini

class AddedLocationCard extends StatelessWidget {
  const AddedLocationCard({super.key});

  // Method untuk mendapatkan deskripsi cuaca
  String _getWeatherDescription(BuildContext context, String iconCode) {
    final Map<String, String> weatherDescriptions = {
      // Cerah
      '01d': 'clear_sky_day',
      '01n': 'clear_sky_night',

      // Sedikit berawan
      '02d': 'few_clouds_day',
      '02n': 'few_clouds_night',

      // Berawan
      '03d': 'scattered_clouds',
      '03n': 'scattered_clouds',

      // Mendung
      '04d': 'broken_clouds',
      '04n': 'broken_clouds',

      // Hujan ringan
      '09d': 'shower_rain',
      '09n': 'shower_rain',

      // Hujan
      '10d': 'rain_day',
      '10n': 'rain_night',

      // Badai
      '11d': 'thunderstorm',
      '11n': 'thunderstorm',

      // Salju
      '13d': 'snow',
      '13n': 'snow',

      // Kabut
      '50d': 'mist',
      '50n': 'mist',
    };

    final descriptionKey = weatherDescriptions[iconCode] ?? 'unknown_weather';
    return context.translate(descriptionKey);
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        if (!authService.isLoggedIn) {
          return Card(
            color: colorScheme.surfaceContainerLow,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off,
                    size: 96,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    context.translate('please_login_add_locations'),
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.tonal(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/settings');
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 56),
                    ),
                    child: Text(
                      context.translate('login'),
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final savedLocations = weatherProvider.savedLocations;

        if (savedLocations.isEmpty) {
          return Card(
            color: colorScheme.surfaceContainerLow,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_location_alt,
                      size: 96,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      context.translate('no_locations_added'),
                      style: textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Card(
          color: colorScheme.surfaceContainerLow,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: savedLocations.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: colorScheme.outlineVariant,
              indent: 16,
              endIndent: 16,
            ),
            itemBuilder: (context, index) {
              final location = savedLocations[index];
              return ListTile(
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                title: Text(
                  location.cityName,
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${location.temperature.toStringAsFixed(1)}°C - ${_getWeatherDescription(context, location.icon)}',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                leading: CircleAvatar(
                  radius: 36,
                  backgroundColor: colorScheme.surfaceVariant,
                  child: Image.network(
                    'http://openweathermap.org/img/wn/${location.icon}@2x.png',
                    width: 56,
                    height: 56,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          WeatherDetailsScreen(weather: location),
                    ),
                  );
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.refresh,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                      onPressed: () {
                        weatherProvider.refreshSavedLocations();
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: colorScheme.error,
                        size: 24,
                      ),
                      onPressed: () {
                        weatherProvider.removeSavedLocation(location);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}