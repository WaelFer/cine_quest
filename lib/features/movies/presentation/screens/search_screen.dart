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
  bool _hasError = false; // New state variable for errors

  void _search() async {
    if (_controller.text.isEmpty) return;

    // Reset states before starting
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final movies = await _apiService.searchMovies(_controller.text);
      setState(() {
        _searchResults = movies;
        _isLoading = false;
      });
    } catch (e) {
      // If it fails, show the Error Screen
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
          decoration: InputDecoration(
            hintText: 'Search movies (e.g., Matrix)...',
            hintStyle: const TextStyle(color: Colors.grey),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: _search,
            ),
          ),
          onSubmitted: (_) => _search(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
          // --- ERROR UI (Matches Home & Watchlist) ---
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text("No Internet Connection", style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _search, // Retry the search with existing text
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
          // -------------------------------------------
          : _searchResults.isEmpty
          ? const Center(
              child: Text("Type a movie name to search", style: TextStyle(color: Colors.grey)),
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
