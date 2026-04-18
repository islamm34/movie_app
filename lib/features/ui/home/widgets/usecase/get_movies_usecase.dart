// lib/features/ui/home/widgets/usecase/get_movies_usecase.dart


import '../../domain/movie_entity.dart';
import '../../repository/repository_impl/movie_repository_impl.dart';

class GetMoviesUseCase {
  final MovieRepositoryImpl repository;

  GetMoviesUseCase(this.repository);

  Future<List<MovieEntity>> execute({
    int page = 1,
    int limit = 20,
    String? genre,
    String? sortBy,
    bool fetchAll = false,
  }) async {
    if (fetchAll) {
      // جلب جميع الأفلام
      final allMovies = await repository.getAllMovies(
        genre: genre,
        sortBy: sortBy,
      );
      return allMovies;
    } else {
      // جلب صفحة واحدة فقط
      return await repository.getMovies(
        page: page,
        limit: limit,
        genre: genre,
        sortBy: sortBy,
      );
    }
  }
}