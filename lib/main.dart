import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

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
import 'screens/loading_screen.dart'; // Tambahkan import loading screen
import 'screens/splash_screen.dart';

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

  // Run the app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
          return MaterialApp(
            title: 'Agung Weather',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            // Use AuthWrapper as the initial route
            home: SplashScreen(),

            // Define named routes
            routes: {
              '/home': (context) => HomeScreen(),
              '/login': (context) => LoginScreen(),
              '/settings': (context) => SettingsScreen(),
            },

            // Add onGenerateRoute for dynamic routing
            onGenerateRoute: (settings) {
              // Handle search route with query parameter
              if (settings.name == '/search') {
                final uri = Uri.parse(settings.name!);
                final cityName = uri.queryParameters['q'];

                return MaterialPageRoute(
                  builder: (context) => SearchScreen(initialQuery: cityName),
                );
              }

              // Handle details route with latitude and longitude
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
                          return LoadingScreen(); // Gunakan LoadingScreen
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

            // Debug configuration
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  // Metode untuk mengambil data cuaca berdasarkan koordinat
  Future<LocationWeather?> _fetchWeatherByCoordinates(
      BuildContext context, double lat, double lon) async {
    final weatherApiService =
    Provider.of<WeatherApiService>(context, listen: false);

    try {
      // Gunakan metode getLocationWeatherByCoordinates yang sudah ada di WeatherApiService
      final weatherData =
      await weatherApiService.getLocationWeatherByCoordinates(lat, lon);
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
        this, '/details?lat=${lat.toString()}&lon=${lon.toString()}');
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Tambahkan kondisi waiting dan gunakan LoadingScreen
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingScreen();
        }

        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;

          if (user == null) {
            // No user is signed in, redirect to login
            return LoginScreen();
          } else {
            // User is signed in, redirect to home
            return HomeScreen();
          }
        }

        // Fallback loading screen
        return LoadingScreen();
      },
    );
  }
}