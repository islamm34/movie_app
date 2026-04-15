// lib/features/ui/home/data_model/movie_model.dart


import '../domain/movie_entity.dart';
import '../home_api/response_api.dart';

class MovieModel extends MovieEntity {
  const MovieModel({
    required super.id,
    required super.title,
    required super.titleEnglish,
    super.titleLong,
    required super.year,
    required super.rating,
    required super.runtime,
    required super.genres,
    required super.summary,
    super.descriptionFull,
    super.ytTrailerCode,
    required super.language,
    super.mpaRating,
    required super.largeCoverImage,
    required super.mediumCoverImage,
    required super.smallCoverImage,
    required super.backgroundImage,
    required super.dateUploaded,
    super.imdbCode,
    super.url,
  });

  // Convert from API response (Movies object)
  factory MovieModel.fromMovies(Movies movie) {
    return MovieModel(
      id: movie.id?.toInt() ?? 0,
      title: movie.title ?? '',
      titleEnglish: movie.titleEnglish ?? '',
      titleLong: movie.titleLong,
      year: movie.year?.toInt() ?? 0,
      rating: movie.rating?.toDouble() ?? 0.0,
      runtime: movie.runtime?.toInt() ?? 0,
      genres: movie.genres ?? [],
      summary: movie.summary ?? '',
      descriptionFull: movie.descriptionFull,
      ytTrailerCode: movie.ytTrailerCode,
      language: movie.language ?? 'en',
      mpaRating: movie.mpaRating,
      largeCoverImage: movie.largeCoverImage ?? '',
      mediumCoverImage: movie.mediumCoverImage ?? '',
      smallCoverImage: movie.smallCoverImage ?? '',
      backgroundImage: movie.backgroundImage ?? '',
      dateUploaded: movie.dateUploaded ?? '',
      imdbCode: movie.imdbCode,  // ✅ أضف هذا
      url: movie.url,             // ✅ أضف هذا
    );
  }

  // Convert from JSON (for local storage)
  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      titleEnglish: json['titleEnglish'] as String? ?? '',
      titleLong: json['titleLong'] as String?,
      year: json['year'] as int? ?? 0,
      rating: json['rating'] is int
          ? (json['rating'] as int).toDouble()
          : json['rating'] as double? ?? 0.0,
      runtime: json['runtime'] as int? ?? 0,
      genres: json['genres'] != null
          ? List<String>.from(json['genres'] as List)
          : [],
      summary: json['summary'] as String? ?? '',
      descriptionFull: json['descriptionFull'] as String?,
      ytTrailerCode: json['ytTrailerCode'] as String?,
      language: json['language'] as String? ?? 'en',
      mpaRating: json['mpaRating'] as String?,
      largeCoverImage: json['largeCoverImage'] as String? ?? '',
      mediumCoverImage: json['mediumCoverImage'] as String? ?? '',
      smallCoverImage: json['smallCoverImage'] as String? ?? '',
      backgroundImage: json['backgroundImage'] as String? ?? '',
      dateUploaded: json['dateUploaded'] as String? ?? '',
      imdbCode: json['imdbCode'] as String?,
      url: json['url'] as String?,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'titleEnglish': titleEnglish,
      'titleLong': titleLong,
      'year': year,
      'rating': rating,
      'runtime': runtime,
      'genres': genres,
      'summary': summary,
      'descriptionFull': descriptionFull,
      'ytTrailerCode': ytTrailerCode,
      'language': language,
      'mpaRating': mpaRating,
      'largeCoverImage': largeCoverImage,
      'mediumCoverImage': mediumCoverImage,
      'smallCoverImage': smallCoverImage,
      'backgroundImage': backgroundImage,
      'dateUploaded': dateUploaded,
      'imdbCode': imdbCode,
      'url': url,
    };
  }
}