import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/weather_provider.dart';
import '../utils/localization.dart';
import '../screens/search_screen.dart';
import '../models/location_weather.dart';
import '../screens/weather_details_screen.dart';

class CurrentLocationCard extends StatefulWidget {
  @override
  _CurrentLocationCardState createState() => _CurrentLocationCardState();
}

class _CurrentLocationCardState extends State<CurrentLocationCard> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _animatedHints = [];
  String _currentHint = '';

  @override
  void initState() {
    super.initState();
    _animatedHints = [
      context.translate('app_name'),
      context.translate('search_city_hint1'),
      context.translate('search_city_hint2'),
      context.translate('search_city_hint3')
    ];
    _currentHint = _animatedHints[0];
    _startHintAnimation();
  }

  void _startHintAnimation() {
    Future.doWhile(() async {
      for (var hint in _animatedHints) {
        await Future.delayed(Duration(seconds: 2));
        setState(() {
          _currentHint = hint;
        });
      }
      return true;
    });
  }

  void _searchCity(String cityName) async {
    try {
      final weatherProvider =
      Provider.of<WeatherProvider>(context, listen: false);

      final result = await weatherProvider.searchWeatherByCity(cityName);

      if (result != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchScreen(initialQuery: cityName),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.translate('city_not_found'))),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.translate('weather_search_failed'))),
      );
    }
  }

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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SearchBar(
                controller: _searchController,
                hintText: _currentHint,
                leading: Icon(Icons.search),
                trailing: [
                  IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                    },
                  ),
                ],
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _searchCity(value);
                  }
                },
              ),
            ),
            Card(
              color: colorScheme.surfaceContainerLow,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildCardContent(
                    context, weatherProvider, colorScheme, textTheme),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCardContent(
      BuildContext context,
      WeatherProvider weatherProvider,
      ColorScheme colorScheme,
      TextTheme textTheme) {
    if (weatherProvider.isLoading) {
      return _buildLoadingCard(context, colorScheme, textTheme);
    }

    if (weatherProvider.locationError != null) {
      return _buildErrorCard(context, weatherProvider, colorScheme, textTheme);
    }

    if (weatherProvider.currentWeather == null) {
      return _buildTurnOnLocationCard(context, weatherProvider, colorScheme, textTheme);
    }

    return _buildWeatherCard(context, weatherProvider, colorScheme, textTheme);
  }

  // Widget loading
  Widget _buildLoadingCard(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: colorScheme.primary),
        SizedBox(height: 16),
        Text(
          context.translate('fetching_location'),
          style: textTheme.titleLarge,
        ),
      ],
    );
  }

  // Widget error
  Widget _buildErrorCard(
      BuildContext context,
      WeatherProvider weatherProvider,
      ColorScheme colorScheme,
      TextTheme textTheme) {
    return Column(
      children: [
        Icon(Icons.error, color: colorScheme.error, size: 72),
        SizedBox(height: 16),
        Text(
          weatherProvider.locationError ?? context.translate('unknown_error'),
          style: textTheme.titleLarge?.copyWith(color: colorScheme.error),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => weatherProvider.refreshCurrentLocation(),
          child: Text(context.translate('retry')),
        ),
      ],
    );
  }

  // Widget turn on location
  Widget _buildTurnOnLocationCard(
      BuildContext context,
      WeatherProvider weatherProvider,
      ColorScheme colorScheme,
      TextTheme textTheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
            Icons.location_off,
            size: 72,
            color: colorScheme.onSurfaceVariant
        ),
        SizedBox(height: 16),
        Text(
          context.translate('location_services_disabled'),
          style: textTheme.titleLarge,
        ),
        SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () async {
            var status = await Permission.location.request();
            if (status.isGranted) {
              weatherProvider.refreshCurrentLocation();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.translate('location_permission_required')),
                ),
              );
            }
          },
          icon: Icon(Icons.location_on),
          label: Text(context.translate ('turn_on_location')),
        ),
      ],
    );
  }

  // Widget cuaca
  // Widget cuaca
  Widget _buildWeatherCard(
      BuildContext context,
      WeatherProvider weatherProvider,
      ColorScheme colorScheme,
      TextTheme textTheme) {
    final currentWeather = weatherProvider.currentWeather!;

    return GestureDetector(
      onTap: () {
        // Konversi currentWeather ke LocationWeather
        final locationWeather = LocationWeather(
          id: DateTime
              .now()
              .millisecondsSinceEpoch
              .toString(),
          cityName: currentWeather.cityName,
          temperature: currentWeather.temperature,
          description: currentWeather.description,
          icon: currentWeather.icon,
          feelsLike: currentWeather.feelsLike,
          minTemp: currentWeather.minTemp,
          maxTemp: currentWeather.maxTemp,
          chanceOfRain: currentWeather.chanceOfRain,
          windSpeed: currentWeather.windSpeed,
          windDirection: currentWeather.windDirection.toInt(),
          sunrise: currentWeather.sunrise,
          sunset: currentWeather.sunset,
          humidity: currentWeather.humidity.toDouble(),
          pressure: currentWeather.pressure.toDouble(),
          visibility: currentWeather.visibility.toDouble(),
        );

        // Navigasi ke halaman detail cuaca
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                WeatherDetailsScreen(weather: locationWeather),
          ),
        );
      },
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
          SizedBox(height: 16),

          // Informasi Cuaca
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ikon Cuaca
              Image.network(
                'http://openweathermap.org/img/wn/${currentWeather
                    .icon}@2x.png',
                width: 100,
                height: 100,
              ),
              SizedBox(width: 16),

              // Detail Suhu
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${currentWeather.temperature.toStringAsFixed(1)}°C',
                    style: textTheme.displaySmall,
                  ),
                  Text(
                    _getWeatherDescription(context, currentWeather.icon),
                    style: textTheme.bodyLarge,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}