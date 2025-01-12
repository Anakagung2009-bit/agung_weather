import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:provider/provider.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/added_location_card.dart';
import '../screens/search_screen.dart';
import '../providers/weather_provider.dart';
import '../utils/localization.dart'; // Tambahkan import ini

class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final TextEditingController _searchController = TextEditingController();

  // List hint text untuk animasi
  List<String> _animatedHints = [];
  String _currentHint = '';

  @override
  void initState() {
    super.initState();
    // Inisialisasi hints dengan terjemahan
    _animatedHints = [
      context.translate('app_name'),
      context.translate('search_city_hint1'),
      context.translate('search_city_hint2'),
      context.translate('search_city_hint3')
    ];
    _currentHint = _animatedHints[0];
    // Mulai animasi hint
    _startHintAnimation();
  }

  void _startHintAnimation() {
    Future.doWhile(() async {
      for (var hint in _animatedHints) {
        await Future.delayed(Duration(seconds: 2));
        setState(() {
          _currentHint = hint;
        });
      }
      return true; // Terus berulang
    });
  }

  void _searchCity(String cityName) async {
    try {
      final weatherProvider =
      Provider.of<WeatherProvider>(context, listen: false);

      final result = await weatherProvider.searchWeatherByCity(cityName);

      if (result != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchScreen(initialQuery: cityName),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.translate('city_not_found'))),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.translate('weather_search_failed'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: SearchBar(
          controller: _searchController,
          hintText: _currentHint,
          leading: Icon(Icons.search),
          trailing: [
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
              },
            ),
          ],
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              _searchCity(value);
            }
          },
        ),
      ),
      body: ListView(
        padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
        children: [
          CurrentWeatherCard(),
          SizedBox(height: 16),
          AddedLocationCard(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}