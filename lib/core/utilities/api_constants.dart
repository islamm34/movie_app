// lib/core/network/api_constants.dart

class ApiConstants {
  static const String baseUrl = 'https://movies-api.accel.li/api/v2';
  static const String oldBaseUrl = 'https://yts.bz/api/v2';

  // Endpoints
  static const String listMovies = '/list_movies.json';
  static const String movieDetails = '/movie_details.json';

  // Query parameters
  static const String paramPage = 'page';
  static const String paramLimit = 'limit';
  static const String paramGenre = 'genre';
  static const String paramSortBy = 'sort_by';
  static const String paramQuality = 'quality';
  static const String paramMinimumRating = 'minimum_rating';
  static const String paramQueryTerm = 'query_term';
  static const String paramMovieId = 'movie_id';
  static const String paramWithImages = 'with_images';
  static const String paramWithCast = 'with_cast';

  // Default values
  static const int defaultLimit = 20;
  static const int defaultPage = 1;
}