import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _key = 'watchlist_ids';

  // Save a list of Movie IDs
  Future<void> saveWatchlist(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, ids);
  }

  // Load the list of Movie IDs
  Future<List<String>> loadWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }
}
