import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../main.dart';
import '../utils/localization.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isLoading = true;

  // Daftar gambar background HD
  final List<String> backgroundImages = [
    'https://images.unsplash.com/photo-1584268721860-cbc7211b1649?w=1920&h=1080=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwcm9maWxlLXBhZ2V8Njl8fHxlbnwwfHx8fHw%3D',
    'https://images.unsplash.com/photo-1584269655525-c2ec535de1d0?w=1920&h=1080=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwcm9maWxlLXBhZ2V8Mzh8fHxlbnwwfHx8fHw%3D',
    'https://images.unsplash.com/photo-1584270247729-818368d097e6?w=1920&h=1080=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwcm9maWxlLXBhZ2V8MTZ8fHxlbnwwfHx8fHw%3D',
    'https://images.unsplash.com/photo-1584265851308-4583e08717fa?w=1920&h=1080=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwcm9maWxlLXBhZ2V8MTQyfHx8ZW58MHx8fHx8',
  ];

  late String _randomBackground;

  @override
  void initState() {
    super.initState();

    // Pilih gambar background secara acak
    _randomBackground = backgroundImages[Random().nextInt(backgroundImages.length)];

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await Future.wait([
        _preloadWeatherData(),
        Future.delayed(const Duration(seconds: 3)),
      ]);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => AuthWrapper()),
      );
    } catch (e) {
      _showErrorDialog();
    }
  }

  Future<void> _preloadWeatherData() async {
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);

    await weatherProvider.fetchCurrentLocationWeather();
    await weatherProvider.fetchSavedLocations();

    setState(() {
      _isLoading = false;
    });
    _animationController.forward();
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Initialization Error'),
        content: Text('Failed to load initial data. Please check your internet connection.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initializeApp();
            },
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image dengan Gradient Overlay
          Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: _randomBackground,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(
                    color: colorScheme.primary,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: colorScheme.surfaceVariant,
                  child: Center(
                    child: Text(
                      'Failed to load background',
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ),
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.6),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                ),
              ),

              // Teks sumber gambar
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Image by Unsplash',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Konten Splash Screen
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Aplikasi dengan Animasi
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1000),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: child,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/icons/icon.png', // Sesuaikan dengan konfigurasi flutter_launcher_icons
                      width: 80,
                      height: 80,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Judul Aplikasi
                Text(
                  'Agung Weather',
                  style: textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                // Material Design 3 Circular Progress Indicator
                CircularProgressIndicator(
                  color: colorScheme.primary,
                  backgroundColor: colorScheme.primaryContainer,
                  strokeWidth: 6,
                  strokeAlign: CircularProgressIndicator.strokeAlignCenter,
                ),

                const SizedBox(height: 20),

                // Loading Text

                Text(
                  context.translate('initializing'),
                  style: textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}