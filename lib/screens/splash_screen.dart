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
        title: Text(context.translate('initialization_error')),
        content: Text(context.translate('failed_to_load_data')),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initializeApp();
            },
            child: Text(context.translate('retry')),
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
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.8),
                ],
              ).createShader(bounds);
            },
            blendMode: BlendMode.darken,
            child: CachedNetworkImage(
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
                    context.translate('failed_to_load_background'),
                    style: textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
          ),

          // Konten Splash Screen
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Aplikasi dengan Animasi
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_animationController.value * 0.2),
                      child: child,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primaryContainer,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.5),
                          blurRadius: 25,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Image.asset(
                      'assets/icons/icon.png',
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Judul Aplikasi
                Text(
                  'Agung Weather',
                  style: textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 30),

                // Loading Indicator dengan Animasi
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    color: colorScheme.primary,
                    strokeWidth: 6,
                    backgroundColor: colorScheme.primaryContainer.withOpacity(0.5),
                  ),
                ),

                const SizedBox (height: 20),

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