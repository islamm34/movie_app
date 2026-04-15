// lib/data/movie/datasources/movie_data_source.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../home_api/response_api.dart';


class MovieDataSource {
  static const String baseUrl = 'https://yts.bz/api/v2';

  Future<ResponseApi> fetchMovies({
    int page = 1,
    int limit = 20,
    String? genre,
    String? sortBy,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (genre != null) queryParams['genre'] = genre;
      if (sortBy != null) queryParams['sort_by'] = sortBy;

      final uri = Uri.parse('$baseUrl/list_movies.json').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ResponseApi.fromJson(json);
      } else {
        throw Exception('Failed to load movies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}