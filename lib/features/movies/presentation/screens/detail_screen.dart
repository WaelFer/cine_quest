import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../watchlist/logic/watchlist_provider.dart';

class DetailScreen extends ConsumerWidget {
  final Map<String, dynamic> movie;

  const DetailScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Prepare Data
    final movieId = movie['id'].toString();
    final posterPath = movie['poster_path'];
    final backdropPath = movie['backdrop_path'];

    final posterUrl = posterPath != null
        ? 'https://image.tmdb.org/t/p/w500$posterPath'
        : 'https://via.placeholder.com/500x750';

    final backdropUrl = backdropPath != null ? 'https://image.tmdb.org/t/p/w780$backdropPath' : posterUrl;

    // 2. WATCH THE STATE
    final watchlist = ref.watch(watchlistProvider);
    final isFavorite = watchlist.contains(movieId);

    return Scaffold(
      appBar: AppBar(title: Text(movie['title'] ?? 'Details'), backgroundColor: Colors.transparent),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER IMAGE ---
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: backdropUrl,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[900]),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black, Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // --- MOVIE INFO ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie['title'] ?? 'Unknown',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${movie['vote_average']?.toStringAsFixed(1) ?? "N/A"} / 10',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(width: 20),
                      const Icon(Icons.calendar_today, color: Colors.grey, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        movie['release_date']?.split('-')[0] ?? 'N/A',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400), // Limits width on big screens
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ref.read(watchlistProvider.notifier).toggleMovie(movieId);

                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isFavorite ? "Removed from Watchlist" : "Added to Watchlist"),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          icon: Icon(isFavorite ? Icons.check : Icons.add),
                          label: Text(isFavorite ? "In Watchlist" : "Add to Watchlist"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFavorite ? Colors.grey : const Color(0xFFE50914),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: const StadiumBorder(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text("Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    movie['overview'] ?? 'No description available.',
                    style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
