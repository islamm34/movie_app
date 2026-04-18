// lib/features/ui/home/data_model/data_source/movie_data_source.dart

import 'package:dio/dio.dart';
import '../../../../../core/network/dio_client.dart';
import '../../home_api/response_api.dart';

class MovieDataSource {
  final DioClient _dioClient = DioClient();

  Future<ResponseApi> fetchMovies({
    int page = 1,
    int limit = 50,
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

  // جلب جميع الأفلام من جميع الصفحات
  Future<List<Movies>> fetchAllMovies({
    String? genre,
    String? sortBy = 'date_added',
    int limit = 50,
  }) async {
    List<Movies> allMovies = [];
    int currentPage = 1;
    int totalMovies = 0;

    try {
      while (true) {
        final response = await fetchMovies(
          page: currentPage,
          limit: limit,
          genre: genre,
          sortBy: sortBy,
        );

        if (response.data?.movies != null && response.data!.movies!.isNotEmpty) {
          allMovies.addAll(response.data!.movies!);
          totalMovies = response.data?.movieCount?.toInt() ?? 0;

          // إذا وصلنا إلى آخر صفحة أو لم يعد هناك أفلام
          if (allMovies.length >= totalMovies || response.data!.movies!.length < limit) {
            break;
          }
          currentPage++;
        } else {
          break;
        }
      }

      print('✅ Fetched ${allMovies.length} movies from $currentPage pages');
      return allMovies;
    } catch (e) {
      print('Error fetching all movies: $e');
      return allMovies;
    }
  }
}