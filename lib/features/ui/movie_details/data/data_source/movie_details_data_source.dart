// lib/data/movie_details/datasources/movie_details_data_source.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../api_responsed/api_responsed.dart';

class MovieDetailsDataSource {

  static const String baseUrl = 'https://movies-api.accel.li/api/v2';

  Future<ApiResponsed> fetchMovieDetails(int movieId) async {
    try {
      final uri = Uri.parse('$baseUrl/movie_details.json').replace(
        queryParameters: {
          'movie_id': movieId.toString(),
          'with_images': 'true',
          'with_cast': 'true',
        },
      );

      print('Fetching movie details from: $uri');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApiResponsed.fromJson(json as Map<String, dynamic>);
      } else {
        throw Exception('Failed to load movie details: ${response.statusCode}');
      }
    } catch (e) {
      print('Network error: $e');
      throw Exception('Network error: $e');
    }
  }
}