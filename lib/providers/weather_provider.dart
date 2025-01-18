import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/weather_model.dart';
import '../models/location_weather.dart';
import '../services/location_service.dart';
import '../services/weather_api_service.dart';
import '../services/location_weather_service.dart';
import 'package:flutter/services.dart';

class WeatherProvider with ChangeNotifier {
  static const String _apiKey = '48f97dbc04acb75d0677c86f678fca93';

  // Inisialisasi logger
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  WeatherModel? _currentWeather;
  bool _isLoading = false;
  String? _locationError;
  bool _isFirstLoad = true;

  final LocationService _locationService = LocationService();
  final WeatherApiService _weatherApiService = WeatherApiService();
  final LocationWeatherService _locationWeatherService = LocationWeatherService();
  final WeatherWidgetService _weatherWidgetService = WeatherWidgetService();

  List<LocationWeather> _savedLocations = [];
  List<WeatherModel> _searchResults = [];

  // Getter
  WeatherModel? get currentWeather => _currentWeather;
  List<LocationWeather> get savedLocations => _savedLocations;
  List<WeatherModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get locationError => _locationError;
  bool get isFirstLoad => _isFirstLoad;

  WeatherProvider() {
    _initializeWeather();
  }

  Future<void> _initializeWeather() async {
    try {
      // Pertama, muat data terakhir dari SharedPreferences
      await loadLastKnownWeather();

      // Muat lokasi tersimpan
      await fetchSavedLocations();

      // Fetch cuaca lokasi saat ini
      await fetchCurrentLocationWeather();

      // Set flag first load
      _isFirstLoad = false;
    } catch (e) {
      _logger.e('Error initializing weather', error: e);
      _isFirstLoad = false;
    }
  }

  // Simpan data cuaca ke SharedPreferences
  Future<void> saveWeatherToSharedPreferences() async {
    try {
      if (_currentWeather != null) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('last_city', _currentWeather!.cityName);
        await prefs.setDouble('last_temp', _currentWeather!.temperature);
        await prefs.setString('last_description', _currentWeather!.description);
        await prefs.setString('last_icon', _currentWeather!.icon);
        await prefs.setInt('last_update_timestamp', DateTime.now().millisecondsSinceEpoch);

        // Update widget Android
        await _weatherWidgetService.updateWeatherWidget(
            _currentWeather!.cityName,
            _currentWeather!.temperature.toStringAsFixed(1),
            _currentWeather!.description
        );
      }
    } catch (e) {
      _logger.e('Error saving weather to SharedPreferences', error: e);
    }
  }

  // Muat data cuaca terakhir dari SharedPreferences
  Future<void> loadLastKnownWeather() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final lastCity = prefs.getString('last_city');
      final lastTemp = prefs.getDouble('last_temp');
      final lastDescription = prefs.getString('last_description');
      final lastIcon = prefs.getString('last_icon');
      final lastUpdateTimestamp = prefs.getInt('last_update_timestamp');

      // Cek validitas data
      if (lastCity != null &&
          lastTemp != null &&
          lastDescription != null &&
          lastIcon != null &&
          lastUpdateTimestamp != null) {

        final currentTime = DateTime.now().millisecondsSinceEpoch;
        final dataAge = currentTime - lastUpdateTimestamp;

        // Jika data kurang dari 1 jam
        if (dataAge < 3600000) {
          _currentWeather = WeatherModel(
            cityName: lastCity,
            temperature: lastTemp,
            description: lastDescription,
            icon: lastIcon,
            feelsLike: 0.0,
            minTemp: 0.0,
            maxTemp: 0.0,
            chanceOfRain: 0,
            windSpeed: 0.0,
            windDirection: 0.0,
            sunrise: DateTime.now(),
            sunset: DateTime.now(),
            timestamp: DateTime.now(),
          );

          notifyListeners();
        }
      }
    } catch (e) {
      _logger.e('Error loading last known weather', error: e);
    }
  }

  // Fetch cuaca lokasi saat ini
  Future<void> fetchCurrentLocationWeather() async {
    try {
      // Set loading state
      _isLoading = true;
      _locationError = null;
      notifyListeners();

      // Periksa layanan lokasi
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _locationError = 'Location services are disabled';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Dapatkan posisi
      final position = await _locationService.getCurrentLocation();

      if (position != null) {
        // Dapatkan cuaca berdasarkan koordinat
        final weather = await _weatherApiService.getWeatherByLocation(
            position.latitude, position.longitude);

        if (weather != null) {
          _currentWeather = weather;
          _locationError = null;

          // Simpan data cuaca
          await saveWeatherToSharedPreferences();
        } else {
          _locationError = 'Failed to fetch weather data';
        }
      } else {
        _locationError = 'Unable to get current location';
      }
    } catch (e) {
      _locationError = 'Error: ${e.toString()}';
      if (kDebugMode) {
        _logger.e('Error fetching current location weather', error: e);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cari cuaca berdasarkan nama kota
  Future<WeatherModel?> searchWeatherByCity(String cityName) async {
    try {
      final weather = await _weatherApiService.getWeatherByCityName(cityName);
      return weather;
    } catch (e) {
      _logger.e('Error searching weather by city', error: e);
      return null;
    }
  }

  // Cari lokasi berdasarkan query
  Future<List<WeatherModel>> searchLocationsByQuery(String query) async {
    try {
      _isLoading = true;
      _searchResults.clear();

      final geocodingUrl = 'http://api.openweathermap.org/geo/1.0/direct?q=$query&limit=50&appid=$_apiKey';

      final geocodingResponse = await http.get(Uri.parse(geocodingUrl));

      if (geocodingResponse.statusCode == 200) {
        List<dynamic> geocodingData = json.decode(geocodingResponse.body);

        List<WeatherModel> results = [];

        // Proses secara bersamaan
        await Future.wait(geocodingData.map((location) async {
          try {
            final weatherUrl = 'https://api.openweathermap.org/data/2.5/weather?lat=${location['lat']}&lon=${location['lon']}&appid=$_apiKey&units=metric';

            final weatherResponse = await http.get(Uri.parse(weatherUrl));

            if (weatherResponse.statusCode == 200) {
              final weatherData = json.decode(weatherResponse.body);

              results.add(WeatherModel(
                cityName: '${location['name']}, ${location['country']}',
                temperature: weatherData['main']['temp'].toDouble(),
                description: weatherData['weather'][0]['description'],
                icon: weatherData['weather'][0]['icon'],
                feelsLike: weatherData['main']['feels_like'].toDouble(),
                minTemp: weatherData['main']['temp_min'].toDouble(),
                maxTemp: weatherData['main']['temp_max'].toDouble(),
                chanceOfRain: 0,
                windSpeed: weatherData['wind']['speed'].toDouble(),
                windDirection: weatherData['wind']['deg'].toDouble(),
                sunrise: DateTime.fromMillisecondsSinceEpoch(weatherData['sys']['sunrise'] * 1000),
                sunset: DateTime.fromMillisecondsSinceEpoch(weatherData['sys']['sunset'] * 1000),
                timestamp: DateTime.now(),
              ));
            }
          } catch (e) {
            _logger.e('Error processing location: $e');
          }
        }), eagerError: true);

        // Urutkan berdasarkan nama kota
        results.sort((a, b) => a.cityName.compareTo(b.cityName));

        _searchResults = results;
        _isLoading = false;

        return results;
      }

      _isLoading = false;
      return [];
    } catch (e) {
      _logger.e('Error searching locations', error: e);
      _isLoading = false;
      return [];
    }
  }

  Future<void> addSavedLocation(WeatherModel weather) async {
    try {
      await _locationWeatherService.saveLocationWeather(weather);
      await fetchSavedLocations();
    } catch (e) {
      _logger.e('Error adding saved location', error: e);
    }
  }

  Future<void> removeSavedLocation(LocationWeather location) async {
    try {
      await _locationWeatherService.deleteLocationWeather(location.cityName);
      await fetchSavedLocations();
    } catch (e) {
      _logger.e('Error removing saved location', error: e);
    }
  }

  Future<void> fetchSavedLocations() async {
    try {
      _savedLocations = await _locationWeatherService.getLocationWeathers();
      notifyListeners();
    } catch (e) {
      _logger.e('Error fetching saved locations', error: e);
    }
  }

  Future<void> clearSavedLocations() async {
    try {
      await Future.forEach(_savedLocations, (LocationWeather location) async {
        await _locationWeatherService.deleteLocationWeather(location.cityName);
      });

      _savedLocations.clear();
      notifyListeners();
    } catch (e) {
      _logger.e('Error clearing saved locations', error: e);
    }
  }

  // Metode refresh lokasi
  Future<void> refreshCurrentLocation() async {
    await fetchCurrentLocationWeather();
  }

  // Refresh added location
  Future<void> refreshSavedLocations() async {
    try {
      final currentLocations = List<LocationWeather>.from(_savedLocations);
      _savedLocations.clear();
      notifyListeners();

      for (var location in currentLocations) {
        try {
          final updatedWeather = await searchWeatherByCity(location.cityName);
          if (updatedWeather != null) {
            await addSavedLocation(updatedWeather);
          } else {
            _savedLocations.add(location);
          }
        } catch (e) {
          _savedLocations.add(location);
          _logger.e('Error refreshing location: ${location.cityName}', error: e);
        }
      }

      notifyListeners();
    } catch (e) {
      _logger.e('Error in refreshSavedLocations', error: e);
    }
  }

  Future<WeatherModel?> searchWeatherByCoordinates(double latitude, double longitude) async {
    try {
      final response = await http.get(
          Uri.parse(
              'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric'
          )
      );

      if (response.statusCode == 200) {
        return WeatherModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      _logger.e('Error searching weather by coordinates: $e');
      return null;
    }
  }

  // Metode konversi suhu
  double convertTemperature(double temp, {bool toCelsius = true}) {
    return toCelsius ? temp : (temp * 9 / 5) + 32;
  }
}

class WeatherWidgetService {
  static const platform = MethodChannel('com.agungdev.weather/weather_widget');

  Future<void> updateWeatherWidget(
      String cityName, String temperature, String description) async {
    try {
      await platform.invokeMethod('updateWeatherWidget', {
        'cityName': cityName,
        'temperature': temperature,
        'description': description,
      });
    } catch (e) {
      print('Failed to update widget: $e');
    }
  }
}