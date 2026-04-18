
import '../../data_model/data_source/movie_data_source.dart';
import '../../data_model/movie_model.dart';
import '../../domain/movie_entity.dart';

class MovieRepositoryImpl {
  final MovieDataSource dataSource;

  MovieRepositoryImpl({required this.dataSource});

  // جلب صفحة واحدة فقط
  Future<List<MovieEntity>> getMovies({
    int page = 1,
    int limit = 20,
    String? genre,
    String? sortBy,
  }) async {
    try {
      final response = await dataSource.fetchMovies(
        page: page,
        limit: limit,
        genre: genre,
        sortBy: sortBy,
      );

      if (response.data?.movies != null && response.data!.movies != null) {
        return response.data!.movies!
            .map((movie) => MovieModel.fromMovies(movie) as MovieEntity)
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching movies: $e');
      return [];
    }
  }

  // ✅ إضافة دالة getAllMovies
  Future<List<MovieEntity>> getAllMovies({
    String? genre,
    String? sortBy = 'date_added',
  }) async {
    try {
      final allMovies = await dataSource.fetchAllMovies(
        genre: genre,
        sortBy: sortBy,
      );

      return allMovies
          .map((movie) => MovieModel.fromMovies(movie) as MovieEntity)
          .toList();
    } catch (e) {
      print('Error fetching all movies: $e');
      return [];
    }
  }
}