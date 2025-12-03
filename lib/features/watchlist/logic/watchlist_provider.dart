import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/storage_service.dart';

// 1. The State Class: Manages the list of IDs
class WatchlistNotifier extends StateNotifier<List<String>> {
  final StorageService _storageService;

  WatchlistNotifier(this._storageService) : super([]) {
    _loadInitialData();
  }

  // Load saved data when the app starts
  Future<void> _loadInitialData() async {
    state = await _storageService.loadWatchlist();
  }

  // Toggle: Add if not there, Remove if it is
  Future<void> toggleMovie(String movieId) async {
    if (state.contains(movieId)) {
      // Remove it
      state = state.where((id) => id != movieId).toList();
    } else {
      // Add it
      state = [...state, movieId];
    }
    // Save to disk (Criterion V3)
    await _storageService.saveWatchlist(state);
  }
}

// 2. The Provider Definition: This is what the UI talks to
final watchlistProvider = StateNotifierProvider<WatchlistNotifier, List<String>>((ref) {
  return WatchlistNotifier(StorageService());
});
