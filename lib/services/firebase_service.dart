import 'package:firebase_database/firebase_database.dart';
import '../models/weather_model.dart';

class FirebaseService {
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref(); // Ganti 'reference()' dengan 'ref()'

  Future<void> saveWeatherData(WeatherModel weather) async {
    await _database.child('weather').push().set({
      'cityName': weather.cityName,
      'temperature': weather.temperature,
      'description': weather.description,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<WeatherModel>> getWeatherData() {
    return _database.child('weather').onValue.map((event) {
      final Map<dynamic, dynamic>? data =
          event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) return [];

      return data.values
          .map((weatherData) => WeatherModel(
                cityName: weatherData['cityName'],
                temperature: weatherData['temperature'],
                description: weatherData['description'],
                icon: '', // Not stored in Firebase
                timestamp: DateTime.parse(weatherData['timestamp']),
              ))
          .toList();
    });
  }
}
