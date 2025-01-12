import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/weather_provider.dart';
import '../models/weather_model.dart';
import '../models/location_weather.dart';
import '../screens/weather_details_screen.dart';
import '../utils/localization.dart'; // Tambahkan import ini


// Extension untuk kapitalisasi string
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}

class WorldMapScreen extends StatefulWidget {
  const WorldMapScreen({Key? key}) : super(key: key);

  @override
  _WorldMapScreenState createState() => _WorldMapScreenState();
}


class _WorldMapScreenState extends State<WorldMapScreen> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  LatLng? _selectedLocation;
  WeatherModel? _selectedWeather;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Method _getWEather
  Widget _getWeatherIcon(String iconCode) {
    final colorScheme = Theme.of(context).colorScheme;

    // Map ikon cuaca
    final Map<String, IconData> weatherIcons = {
      // Cerah
      '01d': Icons.wb_sunny,
      '01n': Icons.nights_stay,

      // Sedikit berawan
      '02d': Icons.wb_cloudy,
      '02n': Icons.cloud_outlined,

      // Berawan
      '03d': Icons.cloud,
      '03n': Icons.cloud,

      // Mendung
      '04d': Icons.cloud_queue,
      '04n': Icons.cloud_queue,

      // Hujan ringan
      '09d': Icons.water_drop_outlined,
      '09n': Icons.water_drop_outlined,

      // Hujan
      '10d': Icons.water_drop,
      '10n': Icons.water_drop,

      // Badai
      '11d': Icons.thunderstorm,
      '11n': Icons.thunderstorm,

      // Salju
      '13d': Icons.ac_unit,
      '13n': Icons.ac_unit,

      // Kabut
      '50d': Icons.foggy,
      '50n': Icons.foggy,
    };

    // Default icon jika tidak ditemukan
    final defaultIcon = Icons.help_outline;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.all(12),
      child: Icon(
        weatherIcons[iconCode] ?? defaultIcon,
        size: 64,
        color: colorScheme.primary,
      ),
    );
  }

// Metode untuk mendapatkan deskripsi cuaca
  String _getWeatherDescription(String iconCode) {
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
  // Method _buildWeatherDetail
  Widget _buildWeatherDetail({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme
        .of(context)
        .colorScheme;
    final textTheme = Theme
        .of(context)
        .textTheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            icon,
            color: colorScheme.primary,
            size: 32,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  // Konversi WeatherModel ke LocationWeather
  LocationWeather _convertToLocationWeather(WeatherModel weatherModel) {
    return LocationWeather(
      id: DateTime
          .now()
          .millisecondsSinceEpoch
          .toString(),
      cityName: weatherModel.cityName,
      temperature: weatherModel.temperature,
      description: weatherModel.description,
      icon: weatherModel.icon,
      feelsLike: weatherModel.feelsLike,
      minTemp: weatherModel.minTemp,
      maxTemp: weatherModel.maxTemp,
      chanceOfRain: weatherModel.chanceOfRain,
      windSpeed: weatherModel.windSpeed,
      windDirection: weatherModel.windDirection.toInt(),
      sunrise: weatherModel.sunrise,
      sunset: weatherModel.sunset,
      humidity: weatherModel.humidity.toDouble(),
      pressure: weatherModel.pressure.toDouble(),
      visibility: weatherModel.visibility.toDouble(),
    );
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) async {
    try {
      // Tampilkan loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary
                ),
              ),
            ),
      );

      // Cari nama kota terdekat atau cuaca di lokasi
      final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
      final weather = await weatherProvider.searchWeatherByCoordinates(
          point.latitude,
          point.longitude
      );

      // Tutup loading
      Navigator.of(context).pop();

      if (weather != null) {
        // Tampilkan bottom sheet
        _showWeatherBottomSheet(weather);

        setState(() {
          _selectedLocation = point;
          _selectedWeather = weather;
        });

        // Jalankan animasi
        _animationController.forward(from: 0.0);
      }
    } catch (e) {
      // Tutup loading
      Navigator.of(context).pop();

      // Tampilkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.translate('failed_to_fetch_weather')),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showWeatherBottomSheet(WeatherModel weather) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ikon cuaca dengan kondisi
                  _getWeatherIcon(weather.icon),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weather.cityName,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          _getWeatherDescription(weather.icon),
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_location_alt, color: colorScheme.primary),
                    onPressed: () {
                      weatherProvider.addSavedLocation(weather);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            context.translate('added_to_saved_locations')
                                .replaceAll('{city}', weather.cityName),
                          ),
                          backgroundColor: colorScheme.primaryContainer,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                    tooltip: context.translate('add_location'),
                  ),
                ],
              ),
              // ... (bagian lain tetap sama)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildWeatherDetail(
                    icon: Icons.thermostat,
                    label: context.translate('temperature'),
                    value: '${weather.temperature.toStringAsFixed(1)}°C',
                  ),
                  _buildWeatherDetail(
                    icon: Icons.wb_sunny,
                    label: context.translate('feels_like'),
                    value: '${weather.feelsLike.toStringAsFixed(1)}°C',
                  ),
                  _buildWeatherDetail(
                    icon: Icons.air,
                    label: context.translate('wind'),
                    value: '${weather.windSpeed.toStringAsFixed(1)} km/h',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  // Navigasi ke halaman detail cuaca
                  Navigator.of(context).pop(); // Tutup bottom sheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WeatherDetailsScreen(
                        weather: _convertToLocationWeather(weather),
                      ),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(context.translate('see_details')),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final weatherProvider = Provider.of<WeatherProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate('world_weather_map')),
        centerTitle: true,
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(0, 0),
          initialZoom: 2.0,
          onTap: (tapPosition, point) => _onMapTap(tapPosition, point),
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          if (_selectedLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _selectedLocation!,
                  width: 80.0,
                  height: 80.0,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: colorScheme.primary,
                        size: 40,
                      ),
                      // Tambahkan badge/penanda jika lokasi sudah disimpan
                      if (_selectedWeather != null &&
                          weatherProvider.savedLocations.any((loc) =>
                          loc.cityName == _selectedWeather!.cityName))
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}