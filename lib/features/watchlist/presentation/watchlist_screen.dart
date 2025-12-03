import 'package:cine_quest/features/movies/data/api_service.dart';
import 'package:cine_quest/features/movies/presentation/widgets/movie_card.dart';
import 'package:cine_quest/features/watchlist/logic/watchlist_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WatchlistScreen extends ConsumerStatefulWidget {
  const WatchlistScreen({super.key});

  @override
  ConsumerState<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends ConsumerState<WatchlistScreen> {
  final ApiService _apiService = ApiService();

  // Helper to fetch details for all saved IDs
  Future<List<dynamic>> _loadFavoriteMovies(List<String> ids) async {
    final List<Future<dynamic>> futures = [];
    for (var id in ids) {
      futures.add(_apiService.getMovieById(id));
    }
    return await Future.wait(futures);
  }

  @override
  Widget build(BuildContext context) {
    // 1. Listen to the list of IDs from Riverpod
    final movieIds = ref.watch(watchlistProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("My Watchlist"), centerTitle: true),
      body: movieIds.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.movie_filter, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No favorites yet!", style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : FutureBuilder<List<dynamic>>(
              future: _loadFavoriteMovies(movieIds),
              builder: (context, snapshot) {
                // State 1: Loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // State 2: Error (No Internet)
                else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text("No Internet Connection", style: TextStyle(fontSize: 18, color: Colors.grey)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          // Simple setState triggers a rebuild, running the Future again
                          onPressed: () => setState(() {}),
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
                }

                final movies = snapshot.data ?? [];

                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
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
            ),
    );
  }
}
