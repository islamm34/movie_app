// lib/data/movie/repositories/movie_repository_impl.dart

import 'dart:convert';


import 'package:http/http.dart' as http;

import '../../data_model/data_source/movie_data_source.dart';
import '../../data_model/movie_model.dart';
import '../../domain/movie_entity.dart';
import '../../home_api/response_api.dart';

import '../movie_repository.dart';
class MovieRepositoryImpl implements MovieRepository {
  final MovieDataSource dataSource;

  MovieRepositoryImpl({required this.dataSource});

  @override
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

      if (response.data?.movies != null) {
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

  @override
  Future<MovieEntity?> getMovieById(int id) async {
    try {
      final response = await dataSource.fetchMovies();

      if (response.data?.movies != null) {
        final movie = response.data!.movies!.firstWhere(
              (m) => m.id == id,
          orElse: () => throw Exception('Movie not found'),
        );
        return MovieModel.fromMovies(movie);
      }

      return null;
    } catch (e) {
      print('Error fetching movie by id: $e');
      return null;
    }
  }

  @override
  Future<List<MovieEntity>> searchMovies(String query) async {
    try {
      final uri = Uri.parse('https://yts.bz/api/v2/list_movies.json')
          .replace(queryParameters: {'query_term': query});


      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final apiResponse = ResponseApi.fromJson(json);

        if (apiResponse.data?.movies != null) {
          return apiResponse.data!.movies!
              .map((movie) => MovieModel.fromMovies(movie) as MovieEntity)
              .toList();
        }
      }

      return [];
    } catch (e) {
      print('Error searching movies: $e');
      return [];
    }
  }
}