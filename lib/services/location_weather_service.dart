import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/weather_model.dart';
import '../models/location_weather.dart';

class LocationWeatherService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Simpan lokasi cuaca untuk user yang sedang login
  Future<void> saveLocationWeather(WeatherModel weather) async {
    try {
      // Pastikan user sudah login
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      DatabaseReference newLocationRef = _database
          .child('user_locations')
          .child(currentUser.uid)
          .child(weather.cityName.toLowerCase().replaceAll(' ', '_'));

      LocationWeather locationWeather = LocationWeather(
        id: newLocationRef.key ?? '',
        cityName: weather.cityName,
        temperature: weather.temperature,
        description: weather.description,
        icon: weather.icon,
        feelsLike: weather.feelsLike,
        minTemp: weather.minTemp,
        maxTemp: weather.maxTemp,
        chanceOfRain: weather.chanceOfRain,
        windSpeed: weather.windSpeed,
        windDirection:
            weather.windDirection.toInt(), // Konversi ke int jika perlu
        sunrise: weather.sunrise,
        sunset: weather.sunset,
      );

      await newLocationRef.set(locationWeather.toJson());

      print('Location weather saved: ${weather.cityName}');
    } catch (e) {
      print('Error saving location weather: $e');
      rethrow;
    }
  }

  // Ambil semua lokasi cuaca untuk user yang sedang login
  Future<List<LocationWeather>> getLocationWeathers() async {
    try {
      // Pastikan user sudah login
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return [];
      }

      DatabaseEvent event =
          await _database.child('user_locations').child(currentUser.uid).once();

      List<LocationWeather> locations = [];

      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> locationsMap =
            event.snapshot.value as Map<dynamic, dynamic>;

        locationsMap.forEach((key, value) {
          locations.add(
              LocationWeather.fromJson(Map<String, dynamic>.from(value), key));
        });
      }

      return locations;
    } catch (e) {
      print('Error getting location weathers: $e');
      return [];
    }
  }

  // Hapus lokasi cuaca untuk user yang sedang login
  Future<void> deleteLocationWeather(String cityName) async {
    try {
      // Pastikan user sudah login
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      await _database
          .child('user_locations')
          .child(currentUser.uid)
          .child(cityName.toLowerCase().replaceAll(' ', '_'))
          .remove();

      print('Location weather deleted: $cityName');
    } catch (e) {
      print('Error deleting location weather: $e');
      rethrow;
    }
  }
}
