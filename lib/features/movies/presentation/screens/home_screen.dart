import 'package:flutter/material.dart';
import '../../data/api_service.dart';
import '../widgets/movie_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _moviesFuture;

  // --- FILTER STATE ---
  String? _selectedGenreId;
  String? _selectedYear;

  // TMDB Genre Map
  final Map<String, String> _genres = {
    'Action': '28',
    'Adventure': '12',
    'Comedy': '35',
    'Drama': '18',
    'Fantasy': '14',
    'Horror': '27',
    'Sci-Fi': '878',
    'Thriller': '53',
  };

  // Generate years list (2025 down to 2000)
  final List<String> _years = List.generate(26, (index) => (2025 - index).toString());

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  void _loadMovies() {
    setState(() {
      // Logic: If filters are set, use discover API. Otherwise, get Trending.
      if (_selectedGenreId != null || _selectedYear != null) {
        _moviesFuture = _apiService.getFilteredMovies(genreId: _selectedGenreId, year: _selectedYear);
      } else {
        _moviesFuture = _apiService.getTrendingMovies();
      }
    });
  }

  // Helper to clear filters
  void _clearFilters() {
    setState(() {
      _selectedGenreId = null;
      _selectedYear = null;
    });
    Navigator.pop(context); // Close the sheet
    _loadMovies(); // Reload Trending
  }

  // --- THE FILTER UI (Bottom Sheet) ---
  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        // We use StatefulBuilder here so the Dropdowns update INSIDE the sheet
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Filter Movies",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 20),

                  // Genre Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedGenreId,
                    dropdownColor: const Color(0xFF333333),
                    decoration: const InputDecoration(
                      labelText: "Genre",
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                    style: const TextStyle(color: Colors.white),
                    items: _genres.entries.map((entry) {
                      return DropdownMenuItem(value: entry.value, child: Text(entry.key));
                    }).toList(),
                    onChanged: (value) => setSheetState(() => _selectedGenreId = value),
                  ),
                  const SizedBox(height: 10),

                  // Year Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedYear,
                    dropdownColor: const Color(0xFF333333),
                    decoration: const InputDecoration(
                      labelText: "Year",
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                    style: const TextStyle(color: Colors.white),
                    items: _years.map((year) {
                      return DropdownMenuItem(value: year, child: Text(year));
                    }).toList(),
                    onChanged: (value) => setSheetState(() => _selectedYear = value),
                  ),
                  const SizedBox(height: 20),

                  // Buttons Row
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: _clearFilters,
                          child: const Text("Clear", style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914)),
                          onPressed: () {
                            Navigator.pop(context); // Close sheet
                            _loadMovies(); // Apply filters to the main screen
                          },
                          child: const Text("Apply", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedGenreId != null || _selectedYear != null ? "Filtered Results" : "CineQuest Trending",
          style: const TextStyle(fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: (_selectedGenreId != null || _selectedYear != null) ? const Color(0xFFE50914) : Colors.white,
            ),
            onPressed: _showFilterModal,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _moviesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text("No Internet Connection", style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadMovies,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Retry"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE50914),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No movies found matching criteria."));
          }

          final movies = snapshot.data!;
          return LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
              return GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  return MovieCard(movie: movies[index]);
                },
              );
            },
          );
        },
      ),
    );
  }
}
