import 'package:cine_quest/features/movies/presentation/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'features/movies/presentation/screens/home_screen.dart';
import 'features/watchlist/presentation/watchlist_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // The list of pages we switch between
  final List<Widget> _pages = const [HomeScreen(), SearchScreen(), WatchlistScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Show the correct page based on index
      body: _pages[_currentIndex],

      // The Navigation Bar (Criterion V2)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.black, // Matches dark theme
        selectedItemColor: const Color(0xFFE50914), // Red
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Watchlist'),
        ],
      ),
    );
  }
}
