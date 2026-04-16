// lib/data/movie_details/repositories/movie_details_repository_impl.dart

import '../../data/data_source/movie_details_data_source.dart';
import '../../data/movie_details_model.dart';
import '../../domain/domain_entity/movie_details_entity.dart';
import '../movie_details_repository.dart';

class MovieDetailsRepositoryImpl implements MovieDetailsRepository {
  final MovieDetailsDataSource dataSource;

  MovieDetailsRepositoryImpl({required this.dataSource});

  @override
  Future<MovieDetailsEntity> getMovieDetails(int movieId) async {
    try {
      final response = await dataSource.fetchMovieDetails(movieId);

      if (response.data?.movie != null) {
        return MovieDetailsModel.fromMovie(response.data!.movie!);
      } else {
        throw Exception('Movie not found');
      }
    } catch (e) {
      print('Error fetching movie details: $e');
      throw Exception('Failed to load movie details: $e');
    }
  }
}