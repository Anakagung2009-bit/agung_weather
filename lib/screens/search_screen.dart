import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/weather_provider.dart';
import '../models/weather_model.dart';
import '../models/location_weather.dart';
import 'weather_details_screen.dart';
import 'world_map_screen.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import '../utils/localization.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchScreen({Key? key, this.initialQuery}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _searchCity(widget.initialQuery!);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  final List<String> _recommendedCities = [
    'Jakarta', 'Surabaya', 'Bandung', 'Yogyakarta', 'Bali',
    'London', 'New York', 'Tokyo', 'Paris', 'Sydney'
  ];

  List<WeatherModel> _searchResults = [];
  bool _isLoading = false;

  void _searchCity(String query) async {
    HapticFeedback.lightImpact();
    setState(() {
      _isLoading = true;
      _searchFocusNode.unfocus();
    });

    try {
      final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
      final results = await weatherProvider.searchLocationsByQuery(query);

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });

      if (results.isEmpty) {
        _showErrorSnackBar(query);
      } else {
        _animationController.forward(from: 0.0);
      }
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });

      _showErrorSnackBar(query);
    }
  }

  void _showErrorSnackBar(String cityName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.translate('unable_to_find_weather').replaceAll('{city}', cityName)),
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  LocationWeather _convertToLocationWeather(WeatherModel weatherModel) {
    return LocationWeather(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
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

  void _navigateToWeatherDetails(WeatherModel weather) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WeatherDetailsScreen(
          weather: _convertToLocationWeather(weather),
        ),
      ),
    );
  }

  void _saveLocation(WeatherModel weather) {
    Provider.of<WeatherProvider>(context, listen: false).addSavedLocation(weather);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.translate('added_to_saved_locations').replaceAll('{city}', weather.cityName)),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                context.translate('weather_search'),
                style: textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SearchBar(
                controller: _searchController,
                focusNode: _searchFocusNode,
                hintText: context.translate('search_city_hint'),
                elevation: MaterialStateProperty.all(1),
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 16),
                ),
                leading: const Icon(Icons.search),
                trailing: [
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchResults = [];
                      });
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.translate('quick_picks'),
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => WorldMapScreen())
                      );
                    },
                    icon: Icon(Icons.map, color: colorScheme.primary),
                    label: Text(
                        context.translate('explore_map'),
                        style: TextStyle(color: colorScheme.primary)
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _recommendedCities.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      showCheckmark: false,
                      label: Text(_recommendedCities[index]),
                      onSelected: (_) {
                        _searchController.text = _recommendedCities[index];
                        _searchCity(_recommendedCities[index]);
                      },
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: _buildSearchResults(colorScheme, textTheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(ColorScheme colorScheme, TextTheme textTheme) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: colorScheme.primary,
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_searching,
              size: 100,
              color: colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              context.translate('start_searching'),
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final weather = _searchResults[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CachedNetworkImage(
              imageUrl: 'http://openweathermap.org/img/wn/${weather.icon}@2x.png',
              width: 60,
              height: 60,
              placeholder: (context, url) => CircularProgressIndicator(
                color: colorScheme.primary,
              ),
              errorWidget: (context, url, error) => Icon(
                Icons.error,
                color: colorScheme.error,
              ),
            ),
            title: Text(
              weather.cityName,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${weather.temperature.toStringAsFixed(1)}°C - ${weather.description}',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.save_alt,
                    color: colorScheme.primary,
                  ),
                  onPressed: () => _saveLocation(weather),
                ),
                IconButton(
                  icon: Icon(
                    Icons.chevron_right,
                    color: colorScheme.primary,
                  ),
                  onPressed: () => _navigateToWeatherDetails(weather),
                ),
              ],
            ),
            onTap: () => _navigateToWeatherDetails(weather),
          ),
        );
      },
    );
  }
}