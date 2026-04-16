// lib/domain/movie_details/usecases/get_movie_details_usecase.dart

import '../domain/domain_entity/movie_details_entity.dart';
import '../repository/movie_details_repository.dart';

class GetMovieDetailsUseCase {
  final MovieDetailsRepository repository;

  GetMovieDetailsUseCase(this.repository);

  Future<MovieDetailsEntity> execute(int movieId) async {
    return await repository.getMovieDetails(movieId);
  }
}