import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/weather_model.dart';
import '../models/location_weather.dart'; // Kembalikan import ini

class HourlyForecast {
  final DateTime time;
  final int rainChance;
  final double temperature;

  HourlyForecast({
    required this.time,
    required this.rainChance,
    required this.temperature,
  });
}

class WeatherApiService {
  // GANTI DENGAN API KEY ANDA DARI OPENWEATHERMAP
  final String apiKey = '48f97dbc04acb75d0677c86f678fca93';

  Future<WeatherModel?> getWeatherByLocation(double lat, double lon) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';

    try {
      print('Fetching weather from URL: $url');
      final response = await http.get(Uri.parse(url));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return WeatherModel.fromJson(json.decode(response.body));
      } else {
        print('Failed to load weather data');
        return null;
      }
    } catch (e) {
      print('Error fetching weather: $e');
      return null;
    }
  }

  Future<WeatherModel?> getWeatherByCityName(String cityName) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric';

    try {
      print('Fetching weather for city: $cityName');
      final response = await http.get(Uri.parse(url));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return WeatherModel.fromJson(json.decode(response.body));
      } else {
        print('Failed to load weather data for $cityName');
        return null;
      }
    } catch (e) {
      print('Error fetching weather by city name: $e');
      return null;
    }
  }

  Future<LocationWeather?> getLocationWeatherByCoordinates(
      double lat, double lon) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Generate unique ID (bisa menggunakan timestamp atau kombinasi lat-lon)
        final String id = '${DateTime.now().millisecondsSinceEpoch}';

        return LocationWeather(
          id: id,
          cityName: data['name'] ?? '',
          temperature: data['main']['temp'].toDouble(),
          description: data['weather'][0]['description'] ?? '',
          icon: data['weather'][0]['icon'] ?? '',
          feelsLike: data['main']['feels_like'].toDouble(),
          minTemp: data['main']['temp_min'].toDouble(),
          maxTemp: data['main']['temp_max'].toDouble(),
          chanceOfRain: 0, // OpenWeather API tidak langsung memberikan ini
          windSpeed: data['wind']['speed'].toDouble(),
          windDirection: data['wind']['deg'].toInt(),
          sunrise: DateTime.fromMillisecondsSinceEpoch(
              data['sys']['sunrise'] * 1000),
          sunset:
          DateTime.fromMillisecondsSinceEpoch(data['sys']['sunset'] * 1000),
          humidity: data['main']['humidity'].toDouble(),
          pressure: data['main']['pressure'].toDouble(),
          visibility: (data['visibility'] ?? 0).toDouble(),
        );
      } else {
        print('Failed to load weather data');
        return null;
      }
    } catch (e) {
      print('Error fetching location weather: $e');
      return null;
    }
  }

  // Metode untuk mendapatkan forecast (opsional)
  Future<List<WeatherModel>?> getWeatherForecast(double lat, double lon) async {
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> forecastList = data['list'];

        return forecastList.map((forecast) {
          return WeatherModel.fromJson(forecast);
        }).toList();
      } else {
        print('Failed to load weather forecast');
        return null;
      }
    } catch (e) {
      print('Error fetching weather forecast: $e');
      return null;
    }
  }

  // Metode baru untuk mendapatkan hourly forecast
  Future<List<HourlyForecast>?> getHourlyForecast(
      double lat, double lon) async {
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> forecastList = data['list'];

        // Ambil 12 forecast terdekat (setiap 3 jam)
        return forecastList.take(4).map((forecast) {
          return HourlyForecast(
            time: DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000),
            rainChance:
            ((forecast['pop'] ?? 0) * 100).toInt(), // Probabilitas hujan
            temperature: forecast['main']['temp'].toDouble(),
          );
        }).toList();
      } else {
        print('Failed to load hourly forecast');
        return null;
      }
    } catch (e) {
      print('Error fetching hourly forecast: $e');
      return null;
    }
  }

  // Metode untuk mendapatkan koordinat dari nama kota
  Future<Map<String, double>?> getCityCoordinates(String cityName) async {
    final url =
        'https://api.openweathermap.org/geo/1.0/direct?q=$cityName&limit=1&appid=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          return {'lat': data[0]['lat'], 'lon': data[0]['lon']};
        }
        return null;
      } else {
        print('Failed to get city coordinates');
        return null;
      }
    } catch (e) {
      print('Error fetching city coordinates: $e');
      return null;
    }
  }

  Future<LocationWeather?> getLocationWeatherByCityName(String cityName) async {
    // Pertama, dapatkan koordinat
    final coordinates = await getCityCoordinates(cityName);

    if (coordinates != null) {
      // Kemudian gunakan koordinat untuk mendapatkan data cuaca
      return await getLocationWeatherByCoordinates(
          coordinates['lat']!, coordinates['lon']!);
    }

    return null;
  }
}
