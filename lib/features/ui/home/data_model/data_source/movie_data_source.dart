// lib/features/ui/home/data_model/data_source/movie_data_source.dart

import 'package:dio/dio.dart';

import '../../../../../core/network/dio_client.dart';
import '../../home_api/response_api.dart';

class MovieDataSource {
  final DioClient _dioClient = DioClient();

  Future<ResponseApi> fetchMovies({
    int page = 1,
    int limit = 20,
    String? genre,
    String? sortBy,
    String? quality,
    String? minimumRating,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (genre != null && genre.isNotEmpty) queryParams['genre'] = genre;
      if (sortBy != null && sortBy.isNotEmpty) queryParams['sort_by'] = sortBy;
      if (quality != null && quality.isNotEmpty) queryParams['quality'] = quality;
      if (minimumRating != null && minimumRating.isNotEmpty) {
        queryParams['minimum_rating'] = minimumRating;
      }

      final response = await _dioClient.get(
        '/list_movies.json',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return ResponseApi.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to load movies: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching movies: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<ResponseApi> searchMovies(String queryTerm) async {
    try {
      final response = await _dioClient.get(
        '/list_movies.json',
        queryParameters: {'query_term': queryTerm},
      );

      if (response.statusCode == 200) {
        return ResponseApi.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to search movies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}