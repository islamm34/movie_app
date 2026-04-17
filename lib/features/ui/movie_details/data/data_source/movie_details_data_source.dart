// lib/data/movie_details/datasources/movie_details_data_source.dart

import 'package:dio/dio.dart';
import '../../../../../core/network/dio_client.dart';
import '../../api_responsed/api_responsed.dart';

class MovieDetailsDataSource {
  final DioClient _dioClient =  DioClient();

  Future<ApiResponsed> fetchMovieDetails(int movieId) async {
    try {
      final response = await _dioClient.get(
        '/movie_details.json',
        queryParameters: {
          'movie_id': movieId.toString(),
          'with_images': 'true',
          'with_cast': 'true',
        },
      );

      if (response.statusCode == 200) {
        return ApiResponsed.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to load movie details: ${response.statusCode}');
      }
    } catch (e) {
      print('Network error: $e');
      throw Exception('Network error: $e');
    }
  }
}