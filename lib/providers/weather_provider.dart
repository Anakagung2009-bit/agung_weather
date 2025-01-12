import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/weather_model.dart';
import '../models/location_weather.dart';
import '../services/location_service.dart';
import '../services/weather_api_service.dart';
import '../services/location_weather_service.dart';

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

  final LocationService _locationService = LocationService();
  final WeatherApiService _weatherApiService = WeatherApiService();
  final LocationWeatherService _locationWeatherService = LocationWeatherService();

  List<LocationWeather> _savedLocations = [];

  // Getter
  WeatherModel? get currentWeather => _currentWeather;
  List<LocationWeather> get savedLocations => _savedLocations;
  bool get isLoading => _isLoading;
  String? get locationError => _locationError;

  WeatherProvider() {
    fetchSavedLocations();
    fetchCurrentLocationWeather();
  }

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

  Future<WeatherModel?> searchWeatherByCity(String cityName) async {
    try {
      final weather = await _weatherApiService.getWeatherByCityName(cityName);
      return weather;
    } catch (e) {
      _logger.e('Error searching weather by city', error: e);
      return null;
    }
  }

  // Metode baru untuk pencarian lokasi
  Future<List<WeatherModel>> searchLocationsByQuery(String query) async {
    try {
      final geocodingUrl = 'http://api.openweathermap.org/geo/1.0/direct?q=$query&limit=50&appid=${_weatherApiService.apiKey}';

      final geocodingResponse = await http.get(Uri.parse(geocodingUrl));

      if (geocodingResponse.statusCode == 200) {
        List<dynamic> geocodingData = json.decode(geocodingResponse.body);

        List<WeatherModel> results = [];

        // Proses secara bersamaan untuk mempercepat
        await Future.wait(geocodingData.map((location) async {
          try {
            final weatherUrl = 'https://api.openweathermap.org/data/2.5/weather?lat=${location['lat']}&lon=${location['lon']}&appid=${_weatherApiService.apiKey}&units=metric';

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
            print('Error processing location: $e');
          }
        }), eagerError: true);

        // Urutkan berdasarkan nama kota
        results.sort((a, b) => a.cityName.compareTo(b.cityName));

        // Kembalikan maksimal 20 lokasi
        return results.take(20).toList();
      }

      return [];
    } catch (e) {
      _logger.e('Error searching locations', error: e);
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
      // Hapus semua lokasi tersimpan
      await Future.forEach(_savedLocations, (LocationWeather location) async {
        await _locationWeatherService.deleteLocationWeather(location.cityName);
      });

      // Kosongkan daftar lokasi
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
      // Simpan daftar lokasi saat ini
      final currentLocations = List<LocationWeather>.from(_savedLocations);

      // Bersihkan daftar lokasi tersimpan
      _savedLocations.clear();
      notifyListeners();

      // Proses refresh untuk setiap lokasi
      for (var location in currentLocations) {
        try {
          // Cari cuaca terbaru berdasarkan nama kota
          final updatedWeather = await searchWeatherByCity(location.cityName);

          if (updatedWeather != null) {
            // Simpan lokasi dengan data cuaca terbaru
            await addSavedLocation(updatedWeather);
          } else {
            // Jika gagal, kembalikan lokasi semula
            _savedLocations.add(location);
          }
        } catch (e) {
          // Jika error, kembalikan lokasi semula
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
      print('Error searching weather by coordinates: $e');
      return null;
    }
  }

  // Metode konversi suhu
  double convertTemperature(double temp, {bool toCelsius = true}) {
    return toCelsius ? temp : (temp * 9 / 5) + 32;
  }
}