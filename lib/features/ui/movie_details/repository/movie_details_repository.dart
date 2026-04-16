// lib/domain/movie_details/repositories/movie_details_repository.dart

import '../domain/domain_entity/movie_details_entity.dart';

abstract class MovieDetailsRepository {
  Future<MovieDetailsEntity> getMovieDetails(int movieId);
}