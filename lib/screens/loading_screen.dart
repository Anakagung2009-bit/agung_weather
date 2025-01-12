import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie Animation (pastikan sudah tambahkan dependency)
            Lottie.asset(
              'assets/animations/loading.json', // Tambahkan animasi Lottie
              width: 200,
              height: 200,
              controller: _controller,
            ),
            SizedBox(height: 24),
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: colorScheme.onBackground,
              ),
            ),
            SizedBox(height: 16),
            // Material Design 3 Linear Progress Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: LinearProgressIndicator(
                backgroundColor: colorScheme.surfaceVariant,
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}