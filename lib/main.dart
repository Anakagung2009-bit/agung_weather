import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';

// Import Firebase options
import 'firebase_options.dart';

// Import Providers
import 'providers/weather_provider.dart';
import 'providers/theme_provider.dart';

// Import Services
import 'services/auth_service.dart';
import 'services/weather_api_service.dart';

// Import Screens
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/search_screen.dart';
import 'screens/weather_details_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/disaster_screen.dart'; // Import screen baru

// Import Models
import 'models/location_weather.dart';
import 'models/weather_model.dart';

// Import Theme
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Tambahkan konfigurasi untuk AppWidget
  const MethodChannel widgetChannel = MethodChannel('com.agungdev.weather/weather_widget');

  // Setup method handler untuk update widget
  widgetChannel.setMethodCallHandler((MethodCall call) async {
    switch (call.method) {
      case 'updateWeatherWidget':
        final weatherProvider = WeatherProvider();
        await weatherProvider.refreshCurrentLocation();

        return {
          'cityName': weatherProvider.currentWeather?.cityName ?? 'Unknown',
          'temperature': '${weatherProvider.currentWeather?.temperature.toStringAsFixed(1) ?? '-'}°C',
          'description': weatherProvider.currentWeather?.description ?? 'No data',
        };
      default:
        throw MissingPluginException();
    }
  });

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<WeatherApiService>(create: (_) => WeatherApiService()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return DynamicColorBuilder(
            builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
              // Prioritaskan warna dinamis dari wallpaper
              ColorScheme lightColorScheme = lightDynamic ?? ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              );

              ColorScheme darkColorScheme = darkDynamic ?? ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
              );

              // Jika Material You dinonaktifkan, gunakan warna default
              if (!themeProvider.isMaterialYouEnabled) {
                lightColorScheme = ColorScheme.fromSeed(
                  seedColor: Colors.blue,
                  brightness: Brightness.light,
                );

                darkColorScheme = ColorScheme.fromSeed(
                  seedColor: Colors.blue,
                  brightness: Brightness.dark,
                );
              }

              return MaterialApp(
                title: 'Weather App',
                theme: ThemeData(
                  colorScheme: lightColorScheme,
                  useMaterial3: true,
                  textTheme: AppTheme.productSansTextTheme,
                  fontFamily: 'ProductSans',
                  appBarTheme: AppBarTheme(
                    backgroundColor: lightColorScheme.surface,
                    foregroundColor: lightColorScheme.onSurface,
                  ),
                  scaffoldBackgroundColor: lightColorScheme.background,
                ),
                darkTheme: ThemeData(
                  colorScheme: darkColorScheme,
                  useMaterial3: true,
                  textTheme: AppTheme.productSansTextTheme,
                  fontFamily: 'ProductSans',
                  appBarTheme: AppBarTheme(
                    backgroundColor: darkColorScheme.surface,
                    foregroundColor: darkColorScheme.onSurface,
                  ),
                  scaffoldBackgroundColor: darkColorScheme.background,
                ),
                themeMode: themeProvider.themeMode,
                locale: themeProvider.locale,
                home: SplashScreen(),
                routes: {
                  '/home': (context) => HomeScreen(),
                  '/login': (context) => LoginScreen(),
                  '/settings': (context) => SettingsScreen(),
                  '/disaster': (context) => DisasterScreen(), // Tambahkan route untuk Disaster Screen
                },
                onGenerateRoute: (settings) {
                  // Routing logic tetap sama seperti sebelumnya
                  if (settings.name == '/search') {
                    final uri = Uri.parse(settings.name!);
                    final cityName = uri.queryParameters['q'];

                    return MaterialPageRoute(
                      builder: (context) => SearchScreen(initialQuery: cityName),
                    );
                  }

                  if (settings.name == '/details') {
                    final uri = Uri.parse(settings.name!);
                    final lat = double.tryParse(uri.queryParameters['lat'] ?? '');
                    final lon = double.tryParse(uri.queryParameters['lon'] ?? '');

                    if (lat != null && lon != null) {
                      return MaterialPageRoute(
                        builder: (context) => FutureBuilder<LocationWeather?>(
                          future: _fetchWeatherByCoordinates(context, lat, lon),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return LoadingScreen();
                            }

                            if (snapshot.hasError || !snapshot.hasData) {
                              return Scaffold(
                                body: Center(
                                  child: Text('Unable to fetch weather details'),
                                ),
                              );
                            }

                            return WeatherDetailsScreen(weather: snapshot.data!);
                          },
                        ),
                      );
                    }
                  }
                  return null;
                },
                debugShowCheckedModeBanner: false,
              );
            },
          );
        },
      ),
    );
  }

  // Metode untuk mengambil data cuaca berdasarkan koordinat
  Future<LocationWeather?> _fetchWeatherByCoordinates(
      BuildContext context,
      double lat,
      double lon
      ) async {
    final weatherApiService = Provider.of<WeatherApiService>(
        context,
        listen: false
    );

    try {
      final weatherData = await weatherApiService.getLocationWeatherByCoordinates(lat, lon);
      return weatherData;
    } catch (e) {
      print('Error fetching weather by coordinates: $e');
      return null;
    }
  }
}

// Extension untuk navigasi yang lebih mudah
extension NavigatorExtension on BuildContext {
  void navigateToSearch(String cityName) {
    Navigator.pushNamed(this, '/search?q=$cityName');
  }

  void navigateToDetails(double lat, double lon) {
    Navigator.pushNamed(
        this,
        '/details?lat=${lat.toString()}&lon=${lon.toString()}'
    );
  }

}

// AuthWrapper untuk mengelola otentikasi
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingScreen();
        }

        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;

          if (user == null) {
            return LoginScreen();
          } else {
            return HomeScreen();
          }
        }

        return LoadingScreen();
      },
    );
  }
}