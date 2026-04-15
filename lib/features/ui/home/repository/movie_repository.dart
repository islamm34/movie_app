// lib/domain/movie/repositories/movie_repository.dart

import '../domain/movie_entity.dart';

abstract class MovieRepository {
  Future<List<MovieEntity>> getMovies({
    int page = 1,
    int limit = 20,
    String? genre,
    String? sortBy,
  });

  Future<MovieEntity?> getMovieById(int id);

  Future<List<MovieEntity>> searchMovies(String query);
}