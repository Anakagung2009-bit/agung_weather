import '../models/location_weather.dart'; // Pastikan import ini ada

class WeatherModel {
  final String cityName;
  final double temperature;
  final String description;
  final String icon;
  final DateTime timestamp;

  // Ubah default value menjadi DateTime.now()
  final DateTime sunrise;
  final DateTime sunset;
  final double feelsLike;
  final double minTemp;
  final double maxTemp;
  final int chanceOfRain;
  final double windSpeed;
  final double windDirection;
  final double maxUVIndex;

  // Tambahkan properti baru
  final int humidity;
  final int pressure;
  final int visibility;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.timestamp,
    // Gunakan DateTime.now() sebagai default value
    DateTime? sunrise,
    DateTime? sunset,
    this.feelsLike = 0.0,
    this.minTemp = 0.0,
    this.maxTemp = 0.0,
    this.chanceOfRain = 0,
    this.windSpeed = 0.0,
    this.windDirection = 0.0,
    this.maxUVIndex = 0.0,
    this.humidity = 0,
    this.pressure = 0,
    this.visibility = 0,
  })  :
  // Inisialisasi dengan DateTime.now() jika null
        this.sunrise = sunrise ?? DateTime.now(),
        this.sunset = sunset ?? DateTime.now();

  // Tambahkan factory method dari JSON
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'] ?? 'Unknown',
      temperature: (json['main']['temp'] ?? 0.0).toDouble(),
      description: json['weather'][0]['description'] ?? '',
      icon: json['weather'][0]['icon'] ?? '01d',
      timestamp: DateTime.now(),
      sunrise: DateTime.fromMillisecondsSinceEpoch(
          (json['sys']['sunrise'] ?? 0) * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch(
          (json['sys']['sunset'] ?? 0) * 1000),
      feelsLike: (json['main']['feels_like'] ?? 0.0).toDouble(),
      minTemp: (json['main']['temp_min'] ?? 0.0).toDouble(),
      maxTemp: (json['main']['temp_max'] ?? 0.0).toDouble(),
      chanceOfRain: json['clouds'] != null ? json['clouds']['all'] ?? 0 : 0,
      windSpeed: (json['wind']['speed'] ?? 0.0).toDouble(),
      windDirection: (json['wind']['deg'] ?? 0.0).toDouble(),
      maxUVIndex: 0.0, // OpenWeatherMap tidak menyediakan UV Index secara langsung

      // Tambahkan parsing untuk properti baru
      humidity: json['main']['humidity'] ?? 0,
      pressure: json['main']['pressure'] ?? 0,
      visibility: json['visibility'] ?? 0,
    );
  }

  // Tambahkan method copyWith untuk memudahkan modifikasi
  WeatherModel copyWith({
    String? cityName,
    double? temperature,
    String? description,
    String? icon,
    DateTime? timestamp,
    DateTime? sunrise,
    DateTime? sunset,
    double? feelsLike,
    double? minTemp,
    double? maxTemp,
    int? chanceOfRain,
    double? windSpeed,
    double? windDirection,
    double? maxUVIndex,
    int? humidity,
    int? pressure,
    int? visibility,
  }) {
    return WeatherModel(
      cityName: cityName ?? this.cityName,
      temperature: temperature ?? this.temperature,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      timestamp: timestamp ?? this.timestamp,
      sunrise: sunrise ?? this.sunrise,
      sunset: sunset ?? this.sunset,
      feelsLike: feelsLike ?? this.feelsLike,
      minTemp: minTemp ?? this.minTemp,
      maxTemp: maxTemp ?? this.maxTemp,
      chanceOfRain: chanceOfRain ?? this.chanceOfRain,
      windSpeed: windSpeed ?? this.windSpeed,
      windDirection: windDirection ?? this.windDirection,
      maxUVIndex: maxUVIndex ?? this.maxUVIndex,
      humidity: humidity ?? this.humidity,
      pressure: pressure ?? this.pressure,
      visibility: visibility ?? this.visibility,
    );
  }

  // Method untuk mengkonversi ke LocationWeather
  LocationWeather toLocationWeather() {
    return LocationWeather(
      id: DateTime.now().toString(),
      cityName: cityName,
      temperature: temperature,
      description: description,
      icon: icon,
      feelsLike: feelsLike,
      minTemp: minTemp,
      maxTemp: maxTemp,
      chanceOfRain: chanceOfRain,
      windSpeed: windSpeed,
      windDirection: windDirection.toInt(),
      sunrise: sunrise,
      sunset: sunset,
      humidity: humidity.toDouble(),
      pressure: pressure.toDouble(),
      visibility: visibility.toDouble(),
    );
  }

  // Tambahkan method toString untuk debugging
  @override
  String toString() {
    return 'WeatherModel(cityName: $cityName, temperature: $temperature, description: $description)';
  }
}