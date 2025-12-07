import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // API Key and Base URL
  static const String _apiKey = '351b9f7dbb31bd76c766a7bb47e2c78c';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  // Function to get the trending movies
  Future<List<dynamic>> getTrendingMovies() async {
    // Construct the URL
    final Uri url = Uri.parse('$_baseUrl/trending/movie/week?api_key=$_apiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // If server returns "OK" (200), decode the JSON
        final data = json.decode(response.body);
        return data['results']; // Return the list of movies
      } else {
        throw Exception('Failed to load movies. Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  // Function to get movie details by ID
  Future<Map<String, dynamic>> getMovieById(String id) async {
    final Uri url = Uri.parse('$_baseUrl/movie/$id?api_key=$_apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load movie details');
    }
  }

  // New method to search movies by query
  Future<List<dynamic>> searchMovies(String query) async {
    final Uri url = Uri.parse('$_baseUrl/search/movie?api_key=$_apiKey&query=$query');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['results'];
      } else {
        throw Exception('Failed to search movies');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<dynamic>> getFilteredMovies({String? genreId, String? year}) async {
    // Start with the base discover URL
    String urlString = '$_baseUrl/discover/movie?api_key=$_apiKey&sort_by=popularity.desc';

    // Append filters if they exist
    if (genreId != null) {
      urlString += '&with_genres=$genreId';
    }
    if (year != null) {
      urlString += '&primary_release_year=$year';
    }

    final Uri url = Uri.parse(urlString);

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['results'];
      } else {
        throw Exception('Failed to filter movies');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Fetch video keys (Youtube IDs)
  Future<String?> getMovieTrailer(String movieId) async {
    final Uri url = Uri.parse('$_baseUrl/movie/$movieId/videos?api_key=$_apiKey');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        // Find the first video that is a "Trailer" and hosted on "YouTube"
        final trailer = results.firstWhere(
          (video) => video['type'] == 'Trailer' && video['site'] == 'YouTube',
          orElse: () => null,
        );

        return trailer?['key']; // Returns the YouTube ID (e.g., "d9MyW72ELq0")
      }
    } catch (e) {
      // Ignore errors, just return null (no trailer found)
    }
    return null;
  }
}
