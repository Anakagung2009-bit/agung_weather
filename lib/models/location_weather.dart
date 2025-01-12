class LocationWeather {
  final String id;
  final String cityName;
  final double temperature;
  final String description;
  final String icon;
  final double feelsLike;
  final double minTemp;
  final double maxTemp;
  final int chanceOfRain;
  final double windSpeed;
  final int windDirection;
  final DateTime sunrise;
  final DateTime sunset;

  // Tambahkan field baru
  final double humidity;
  final double pressure;
  final double visibility;

  LocationWeather({
    required this.id,
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.feelsLike,
    required this.minTemp,
    required this.maxTemp,
    required this.chanceOfRain,
    required this.windSpeed,
    required this.windDirection,
    required this.sunrise,
    required this.sunset,

    // Parameter baru
    this.humidity = 0.0,
    this.pressure = 0.0,
    this.visibility = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'temperature': temperature,
      'description': description,
      'icon': icon,
      'feelsLike': feelsLike,
      'minTemp': minTemp,
      'maxTemp': maxTemp,
      'chanceOfRain': chanceOfRain,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'sunrise': sunrise.toIso8601String(),
      'sunset': sunset.toIso8601String(),
      // Tambahkan field baru
      'humidity': humidity,
      'pressure': pressure,
      'visibility': visibility,

    };
  }

  factory LocationWeather.fromJson(Map<String, dynamic> json, String id) {
    return LocationWeather(
      id: id,
      cityName: json['cityName'] ?? '',
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      feelsLike: (json['feelsLike'] ?? 0.0).toDouble(),
      minTemp: (json['minTemp'] ?? 0.0).toDouble(),
      maxTemp: (json['maxTemp'] ?? 0.0).toDouble(),
      chanceOfRain: json['chanceOfRain'] ?? 0,
      windSpeed: (json['windSpeed'] ?? 0.0).toDouble(),
      windDirection: json['windDirection'] ?? 0,
      sunrise: json['sunrise'] != null
          ? DateTime.parse(json['sunrise'])
          : DateTime.now(),
      sunset: json['sunset'] != null
          ? DateTime.parse(json['sunset'])
          : DateTime.now(),
      // Parse field baru
      humidity: (json['humidity'] ?? 0.0).toDouble(),
      pressure: (json['pressure'] ?? 0.0).toDouble(),
      visibility: (json['visibility'] ?? 0.0).toDouble(),
    );
  }
}
