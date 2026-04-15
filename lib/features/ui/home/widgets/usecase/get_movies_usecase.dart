// lib/domain/movie/usecases/get_movies_usecase.dart

import '../../domain/movie_entity.dart';
import '../../repository/movie_repository.dart';

class GetMoviesUseCase {
  final MovieRepository repository;

  GetMoviesUseCase(this.repository);

  Future<List<MovieEntity>> execute({
    int page = 1,
    int limit = 20,
    String? genre,
    String? sortBy,
  }) async {
    return await repository.getMovies(
      page: page,
      limit: limit,
      genre: genre,
      sortBy: sortBy,
    );
  }
}