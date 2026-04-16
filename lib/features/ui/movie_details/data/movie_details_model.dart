// lib/data/movie_details/models/movie_details_model.dart

import '../api_responsed/api_responsed.dart';
import '../domain/cast/cast_model.dart';
import '../domain/domain_entity/movie_details_entity.dart';

class MovieDetailsModel extends MovieDetailsEntity {
  const MovieDetailsModel({
    required super.id,
    required super.url,
    required super.imdbCode,
    required super.title,
    required super.titleEnglish,
    super.titleLong,
    required super.year,
    required super.rating,
    required super.runtime,
    required super.genres,
    required super.likeCount,
    required super.descriptionIntro,
    required super.descriptionFull,
    super.ytTrailerCode,
    required super.language,
    super.mpaRating,
    required super.backgroundImage,
    required super.backgroundImageOriginal,
    required super.smallCoverImage,
    required super.mediumCoverImage,
    required super.largeCoverImage,
    required super.mediumScreenshotImage1,
    required super.mediumScreenshotImage2,
    required super.mediumScreenshotImage3,
    required super.largeScreenshotImage1,
    required super.largeScreenshotImage2,
    required super.largeScreenshotImage3,
    required super.cast,
    required super.dateUploaded,
  });

  // Convert from API response (Movie object)
  factory MovieDetailsModel.fromMovie(Movie movie) {
    return MovieDetailsModel(
      id: movie.id?.toInt() ?? 0,
      url: movie.url ?? '',
      imdbCode: movie.imdbCode ?? '',
      title: movie.title ?? '',
      titleEnglish: movie.titleEnglish ?? '',
      titleLong: movie.titleLong,
      year: movie.year?.toInt() ?? 0,
      rating: movie.rating?.toDouble() ?? 0.0,
      runtime: movie.runtime?.toInt() ?? 0,
      genres: movie.genres ?? [],
      likeCount: movie.likeCount?.toInt() ?? 0,
      descriptionIntro: movie.descriptionIntro ?? '',
      descriptionFull: movie.descriptionFull ?? '',
      ytTrailerCode: movie.ytTrailerCode,
      language: movie.language ?? 'en',
      mpaRating: movie.mpaRating,
      backgroundImage: movie.backgroundImage ?? '',
      backgroundImageOriginal: movie.backgroundImageOriginal ?? '',
      smallCoverImage: movie.smallCoverImage ?? '',
      mediumCoverImage: movie.mediumCoverImage ?? '',
      largeCoverImage: movie.largeCoverImage ?? '',
      mediumScreenshotImage1: movie.mediumScreenshotImage1 ?? '',
      mediumScreenshotImage2: movie.mediumScreenshotImage2 ?? '',
      mediumScreenshotImage3: movie.mediumScreenshotImage3 ?? '',
      largeScreenshotImage1: movie.largeScreenshotImage1 ?? '',
      largeScreenshotImage2: movie.largeScreenshotImage2 ?? '',
      largeScreenshotImage3: movie.largeScreenshotImage3 ?? '',
      cast: movie.cast?.map((c) => CastModel.fromCast(c)).toList() ?? [],
      dateUploaded: movie.dateUploaded ?? '',
    );
  }

  // Convert from JSON
  factory MovieDetailsModel.fromJson(Map<String, dynamic> json) {
    return MovieDetailsModel(
      id: json['id'] as int? ?? 0,
      url: json['url'] as String? ?? '',
      imdbCode: json['imdbCode'] as String? ?? '',
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
      likeCount: json['likeCount'] as int? ?? 0,
      descriptionIntro: json['descriptionIntro'] as String? ?? '',
      descriptionFull: json['descriptionFull'] as String? ?? '',
      ytTrailerCode: json['ytTrailerCode'] as String?,
      language: json['language'] as String? ?? 'en',
      mpaRating: json['mpaRating'] as String?,
      backgroundImage: json['backgroundImage'] as String? ?? '',
      backgroundImageOriginal: json['backgroundImageOriginal'] as String? ?? '',
      smallCoverImage: json['smallCoverImage'] as String? ?? '',
      mediumCoverImage: json['mediumCoverImage'] as String? ?? '',
      largeCoverImage: json['largeCoverImage'] as String? ?? '',
      mediumScreenshotImage1: json['mediumScreenshotImage1'] as String? ?? '',
      mediumScreenshotImage2: json['mediumScreenshotImage2'] as String? ?? '',
      mediumScreenshotImage3: json['mediumScreenshotImage3'] as String? ?? '',
      largeScreenshotImage1: json['largeScreenshotImage1'] as String? ?? '',
      largeScreenshotImage2: json['largeScreenshotImage2'] as String? ?? '',
      largeScreenshotImage3: json['largeScreenshotImage3'] as String? ?? '',
      cast: json['cast'] != null
          ? (json['cast'] as List)
          .map((c) => CastModel.fromJson(c as Map<String, dynamic>))
          .toList()
          : [],
      dateUploaded: json['dateUploaded'] as String? ?? '',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'imdbCode': imdbCode,
      'title': title,
      'titleEnglish': titleEnglish,
      'titleLong': titleLong,
      'year': year,
      'rating': rating,
      'runtime': runtime,
      'genres': genres,
      'likeCount': likeCount,
      'descriptionIntro': descriptionIntro,
      'descriptionFull': descriptionFull,
      'ytTrailerCode': ytTrailerCode,
      'language': language,
      'mpaRating': mpaRating,
      'backgroundImage': backgroundImage,
      'backgroundImageOriginal': backgroundImageOriginal,
      'smallCoverImage': smallCoverImage,
      'mediumCoverImage': mediumCoverImage,
      'largeCoverImage': largeCoverImage,
      'mediumScreenshotImage1': mediumScreenshotImage1,
      'mediumScreenshotImage2': mediumScreenshotImage2,
      'mediumScreenshotImage3': mediumScreenshotImage3,
      'largeScreenshotImage1': largeScreenshotImage1,
      'largeScreenshotImage2': largeScreenshotImage2,
      'largeScreenshotImage3': largeScreenshotImage3,
      'cast': cast.map((c) => (c as CastModel).toJson()).toList(),
      'dateUploaded': dateUploaded,
    };
  }
}