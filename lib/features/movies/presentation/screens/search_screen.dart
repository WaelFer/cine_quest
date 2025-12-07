import 'dart:async'; // Required for the Timer
import 'package:flutter/material.dart';
import '../../data/api_service.dart';
import '../widgets/movie_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _controller = TextEditingController();

  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  bool _hasError = false;

  // The Timer for "Debouncing" (waiting before searching)
  Timer? _debounce;

  @override
  void dispose() {
    // Cancel the timer when we leave the screen to stop memory leaks
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  // This function runs every time you type a letter
  void _onSearchChanged(String query) {
    // 1. Cancel the previous timer (if the user is still typing)
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // 2. Start a new timer for 500ms (0.5 seconds)
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // 3. If user stopped typing for 500ms, run the search
      if (query.isNotEmpty) {
        _performSearch(query);
      } else {
        // If text is empty, clear results
        setState(() {
          _searchResults = [];
          _hasError = false;
        });
      }
    });
  }

  void _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // 1. Get raw results from API
      List<dynamic> movies = await _apiService.searchMovies(query);

      // 2. SORTING LOGIC: Best Rated First
      // 'b' minus 'a' gives descending order (10 -> 0)
      movies.sort((a, b) {
        final double ratingA = (a['vote_average'] ?? 0).toDouble();
        final double ratingB = (b['vote_average'] ?? 0).toDouble();
        return ratingB.compareTo(ratingA);
      });

      setState(() {
        _searchResults = movies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          style: const TextStyle(color: Colors.white),
          // Call our new function whenever text changes
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search movies (e.g., Matrix)...',
            hintStyle: const TextStyle(color: Colors.grey),
            border: InputBorder.none,
            // Clear button instead of Search button
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      _controller.clear();
                      _onSearchChanged(''); // Clear results
                    },
                  )
                : const Icon(Icons.search, color: Colors.grey),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text("No Internet Connection", style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    // Retry with current text
                    onPressed: () => _performSearch(_controller.text),
                    icon: const Icon(Icons.refresh),
                    label: const Text("Retry"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE50914),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : _searchResults.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 64, color: Colors.grey[800]),
                  const SizedBox(height: 16),
                  const Text("Type to search movies...", style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 0.7,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                return MovieCard(movie: _searchResults[index]);
              },
            ),
    );
  }
}
