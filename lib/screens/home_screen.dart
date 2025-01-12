import 'package:flutter/material.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/sidebar.dart'; // Import sidebar
import '../widgets/bottom_navigation.dart';
import 'home_content.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeContent(),
    SearchScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: Scaffold(
        drawer: CustomNavigationDrawer(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
        ),
        body: _screens[_currentIndex],
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
        ),
      ),
      desktop: Scaffold(
        body: Row(
          children: [
            CustomNavigationDrawer(
              currentIndex: _currentIndex,
              onTap: _onItemTapped,
            ),
            Expanded(
              child: _screens[_currentIndex],
            ),
          ],
        ),
      ),
      tablet: Scaffold(
        drawer: CustomNavigationDrawer(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
        ),
        body: _screens[_currentIndex],
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
