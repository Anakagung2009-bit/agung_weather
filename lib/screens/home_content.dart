import 'package:flutter/material.dart';
import '../widgets/current_location_card.dart';
import '../widgets/added_location_card.dart';

class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
        children: [
          CurrentLocationCard(), // SearchBar sudah ada di sini
          SizedBox(height: 16),
          AddedLocationCard(),
        ],
      ),
    );
  }
}