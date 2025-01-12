import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/location_weather.dart';
import '../services/weather_api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/localization.dart';

class WeatherDetailsScreen extends StatefulWidget {
  final LocationWeather weather;

  const WeatherDetailsScreen({Key? key, required this.weather})
      : super(key: key);

  @override
  _WeatherDetailsScreenState createState() => _WeatherDetailsScreenState();
}

class HourlyForecast {
  final DateTime time;
  final int rainChance;
  final double temperature;
  final String icon; // Tambahkan icon

  HourlyForecast({
    required this.time,
    required this.rainChance,
    required this.temperature,
    required this.icon,
  });
}

class _WeatherDetailsScreenState extends State<WeatherDetailsScreen> {
  String _aiSummary = 'Generating weather insights...';
  List<HourlyForecast> _hourlyForecasts = [];
  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
    _generateWeatherSummary();
    _fetchHourlyForecasts();
  }

  Future<void> _generateWeatherSummary() async {
    try {
      final model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: 'AIzaSyDsC521Se6YT1pbEIEZ8i_JK5PlHYIBfSI', // Ganti dengan API key Anda
      );

      final prompt = '''
    ${context.translate('ai_weather_prompt_template')}
    - City: ${widget.weather.cityName}
    - Temperature: ${widget.weather.temperature}°C
    - Description: ${widget.weather.description}
    - Feels Like: ${widget.weather.feelsLike}°C
    - Wind Speed: ${widget.weather.windSpeed} m/s
    - Humidity: ${widget.weather.chanceOfRain}%
    
    ${context.translate('ai_weather_prompt_instructions')}
    ''';

      final response = await model.generateContent(
        [Content.text(prompt)],
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 300,
        ),
      );

      setState(() {
        _aiSummary = response.text ?? context.translate('unable_to_generate_summary');
      });
    } catch (e) {
      setState(() {
        _aiSummary = '${context.translate('error_generating_insights')}: $e';
      });
    }
  }

  Future<void> _fetchHourlyForecasts() async {
    final weatherApiService = WeatherApiService();

    try {
      final coordinates =
          await weatherApiService.getCityCoordinates(widget.weather.cityName);

      if (coordinates != null) {
        final url =
            'https://api.openweathermap.org/data/2.5/forecast?lat=${coordinates['lat']}&lon=${coordinates['lon']}&appid=48f97dbc04acb75d0677c86f678fca93&units=metric';

        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          final List<dynamic> forecastList = data['list'];

          // Filter forecast dari jam 1 PM hingga 12 AM
          List<HourlyForecast> forecasts = forecastList
              .map((forecast) {
                DateTime forecastTime =
                    DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000);
                return HourlyForecast(
                  time: forecastTime,
                  rainChance: ((forecast['pop'] ?? 0) * 100).toInt(),
                  temperature: forecast['main']['temp'].toDouble(),
                  icon: forecast['weather'][0]['icon'],
                );
              })
              .where((forecast) {
                // Filter jam antara 1 PM (13:00) dan 12 AM (00:00)
                return forecast.time.hour >= 13 && forecast.time.hour < 24;
              })
              .take(5) // Ambil maksimal 5 forecast
              .toList();

          setState(() {
            _hourlyForecasts = forecasts;
            _isLoading = false;
          });
        } else {
          print('Failed to load hourly forecast');
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching hourly forecasts: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.weather.cityName),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 1200) {
            return _buildWideDesktopLayout(context);
          } else if (constraints.maxWidth > 600) {
            return _buildMediumDesktopLayout(context);
          } else {
            return _buildMobileLayout(context);
          }
        },
      ),
    );
  }

  Widget _buildAISummaryCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  context.translate('ai_weather_insights'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              _aiSummary,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChanceOfRainCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.water_drop, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  context.translate('chance_of_rain'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            SizedBox(height: 12),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _hourlyForecasts.isEmpty
                ? Center(child: Text(context.translate('no_forecast_data')))
                : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _hourlyForecasts
                    .map((forecast) =>
                    _buildHourlyForecastItem(context, forecast))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyRainChance(
      BuildContext context, String time, int percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              time,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage > 50
                    ? Colors.red
                    : percentage > 20
                        ? Colors.orange
                        : Colors.green,
              ),
              minHeight: 10,
            ),
          ),
          SizedBox(width: 8),
          Text(
            '$percentage%',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyForecastItem(
      BuildContext context, HourlyForecast forecast) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Format jam dengan AM/PM
    String formattedTime = DateFormat('h a').format(forecast.time);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Text(
            formattedTime,
            style: textTheme.bodySmall,
          ),
          Image.network(
            'http://openweathermap.org/img/wn/${forecast.icon}@2x.png',
            width: 50,
            height: 50,
          ),
          Text(
            '${forecast.temperature.toStringAsFixed(1)}°C',
            style: textTheme.bodyMedium,
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.water_drop,
                  size: 16,
                  color: forecast.rainChance > 50 ? Colors.blue : Colors.grey),
              Text(
                '${forecast.rainChance}%',
                style: textTheme.bodySmall?.copyWith(
                  color: forecast.rainChance > 50
                      ? Colors.blue
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Layout methods (Wide Desktop, Medium Desktop, Mobile)
  Widget _buildWideDesktopLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          width: 1200,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildWeatherSummary(context),
                    _buildAISummaryCard(context),
                    _buildChanceOfRainCard(context),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child:
                    _buildWeatherDetailsGrid(context), // Hapus crossAxisCount
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediumDesktopLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildWeatherSummary(context),
          _buildAISummaryCard(context),
          _buildChanceOfRainCard(context),
          _buildWeatherDetailsGrid(context), // Hapus crossAxisCount
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildWeatherSummary(context),
          _buildAISummaryCard(context),
          _buildChanceOfRainCard(context),
          _buildWeatherDetailsGrid(context),
        ],
      ),
    );
  }

  Widget _buildWeatherSummary(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  'http://openweathermap.org/img/wn/${widget.weather.icon}@4x.png',
                  width: 100,
                  height: 100,
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.weather.temperature.toStringAsFixed(1)}°C',
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                    ),
                    Text(
                      widget.weather.description.toUpperCase(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryItem(context,
                    icon: Icons.device_thermostat,
                    label: 'Feels Like',
                    value: '${widget.weather.feelsLike.toStringAsFixed(1)}°C'),
                _buildSummaryItem(context,
                    icon: Icons.water_drop,
                    label: 'Humidity',
                    value: '${widget.weather.humidity.toStringAsFixed(0)}%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context,
      {required IconData icon, required String label, required String value}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Icon(icon, color: colorScheme.primary, size: 30),
        SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildWeatherDetailsGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Tentukan jumlah kolom berdasarkan lebar layar
        int crossAxisCount;
        double childAspectRatio;

        if (constraints.maxWidth > 1200) {
          crossAxisCount = 3;
          childAspectRatio = 1.5;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2;
          childAspectRatio = 1.5;
        } else {
          // Untuk mobile, gunakan grid 2 kolom dengan kartu kecil
          crossAxisCount = 2;
          childAspectRatio = 1.0; // Kartu lebih persegi
        }

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          childAspectRatio: childAspectRatio,
          children: _buildWeatherDetailsWidgets(context),
        );
      },
    );
  }

  List<Widget> _buildWeatherDetailsWidgets(BuildContext context) {
    return [
      _buildDetailCard(
        context,
        icon: Icons.wb_sunny,
        title: context.translate('sunrise'),
        value: DateFormat.jm().format(widget.weather.sunrise),
      ),
      _buildDetailCard(
        context,
        icon: Icons.wb_sunny_outlined,
        title: context.translate('sunset'),
        value: DateFormat.jm().format(widget.weather.sunset),
      ),
      _buildDetailCard(
        context,
        icon: Icons.device_thermostat,
        title: context.translate('min_temp'),
        value: '${widget.weather.minTemp.toStringAsFixed(1)}°C',
      ),
      _buildDetailCard(
        context,
        icon: Icons.device_thermostat,
        title: context.translate('max_temp'),
        value: '${widget.weather.maxTemp.toStringAsFixed(1)}°C',
      ),
      _buildDetailCard(
        context,
        icon: Icons.air,
        title: context.translate('wind_speed'),
        value: '${widget.weather.windSpeed} m/s',
      ),
      _buildDetailCard(
        context,
        icon: Icons.navigation,
        title: context.translate('wind_direction'),
        value: '${widget.weather.windDirection}°',
      ),
    ];
  }


  Widget _buildDetailCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Sedikit lebih kecil
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: colorScheme.primary), // Ikon lebih kecil
          SizedBox(height: 4), // Jarak antar elemen lebih rapat
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetailCard(String title, String value) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(value),
          ],
        ),
      ),
    );
  }
}
