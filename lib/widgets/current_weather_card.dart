import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../models/weather_model.dart';
import '../models/location_weather.dart'; // Tambahkan import ini
import '../screens/weather_details_screen.dart'; // Tambahkan import ini


class CurrentWeatherCard extends StatelessWidget {
  const CurrentWeatherCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        // Kondisi loading
        if (weatherProvider.isLoading) {
          return _buildLoadingCard(context, colorScheme, textTheme);
        }

        // Kondisi error
        if (weatherProvider.locationError != null) {
          return _buildErrorCard(
              context, weatherProvider, colorScheme, textTheme);
        }

        // Kondisi cuaca saat ini
        final currentWeather = weatherProvider.currentWeather;
        if (currentWeather == null) {
          return _buildNoWeatherCard(
              context, weatherProvider, colorScheme, textTheme);
        }

        // Tampilan kartu cuaca
        return _buildWeatherCard(
            context, currentWeather, colorScheme, textTheme);
      },
    );
  }

  // Widget loading
  Widget _buildLoadingCard(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      color: colorScheme.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                'Fetching current location weather...',
                style: textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget error
  Widget _buildErrorCard(BuildContext context, WeatherProvider weatherProvider,
      ColorScheme colorScheme, TextTheme textTheme) {
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
            Icon(Icons.error_outline, color: colorScheme.error, size: 72),
            const SizedBox(height: 24),
            Text(
              weatherProvider.locationError ?? 'Unknown error',
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.tonal(
              onPressed: () {
                weatherProvider.refreshCurrentLocation();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 56),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget tidak ada cuaca
  Widget _buildNoWeatherCard(
      BuildContext context,
      WeatherProvider weatherProvider,
      ColorScheme colorScheme,
      TextTheme textTheme) {
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
            Icon(Icons.cloud_off,
                color: colorScheme.onSurfaceVariant, size: 72),
            const SizedBox(height: 24),
            Text(
              'No weather data available',
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.tonal(
              onPressed: () {
                weatherProvider.refreshCurrentLocation();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 56),
              ),
              child: const Text(
                'Refresh',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget cuaca
  // Widget cuaca
  Widget _buildWeatherCard(BuildContext context, WeatherModel currentWeather,
      ColorScheme colorScheme, TextTheme textTheme) {
    return GestureDetector(
      onTap: () {
        // Konversi WeatherModel ke LocationWeather
        final locationWeather = LocationWeather(
          id: DateTime.now().toString(), // Generate unique ID
          cityName: currentWeather.cityName,
          temperature: currentWeather.temperature,
          description: currentWeather.description,
          icon: currentWeather.icon,
          feelsLike: currentWeather.feelsLike,
          minTemp: currentWeather.minTemp,
          maxTemp: currentWeather.maxTemp,
          chanceOfRain: currentWeather.chanceOfRain,
          windSpeed: currentWeather.windSpeed,
          windDirection: currentWeather.windDirection.toInt(), // Konversi ke int
          sunrise: currentWeather.sunrise,
          sunset: currentWeather.sunset,
          humidity: currentWeather.humidity.toDouble(), // Konversi ke double
          pressure: currentWeather.pressure.toDouble(), // Konversi ke double
          visibility: currentWeather.visibility.toDouble(), // Konversi ke double
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WeatherDetailsScreen(weather: locationWeather),
          ),
        );
      },
      child: Card(
        color: colorScheme.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Nama Kota
              Text(
                currentWeather.cityName,
                style: textTheme.headlineMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Baris Ikon dan Suhu
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ikon Cuaca
                  CachedNetworkImage(
                    imageUrl:
                    'http://openweathermap.org/img/wn/${currentWeather.icon}@4x.png',
                    width: 120,
                    height: 120,
                    placeholder: (context, url) =>
                        CircularProgressIndicator(color: colorScheme.primary),
                    errorWidget: (context, url, error) =>
                        Icon(Icons.error, color: colorScheme.error),
                  ),
                  const SizedBox(width: 24),

                  // Informasi Suhu
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Suhu
                      Text(
                        '${currentWeather.temperature.toStringAsFixed(1)}°C',
                        style: textTheme.displayMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Deskripsi Cuaca
                      Text(
                        _capitalizeFirstLetter(currentWeather.description),
                        style: textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Utility untuk mengkapitalisasi huruf pertama
  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
