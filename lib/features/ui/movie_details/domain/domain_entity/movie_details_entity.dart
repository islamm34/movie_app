// lib/domain/movie_details/entities/movie_details_entity.dart

import '../cast/cast_entity.dart';

class MovieDetailsEntity {
  final int id;
  final String url;
  final String imdbCode;
  final String title;
  final String titleEnglish;
  final String? titleLong;
  final int year;
  final double rating;
  final int runtime;
  final List<String> genres;
  final int likeCount;
  final String descriptionIntro;
  final String descriptionFull;
  final String? ytTrailerCode;
  final String language;
  final String? mpaRating;
  final String backgroundImage;
  final String backgroundImageOriginal;
  final String smallCoverImage;
  final String mediumCoverImage;
  final String largeCoverImage;
  final String mediumScreenshotImage1;
  final String mediumScreenshotImage2;
  final String mediumScreenshotImage3;
  final String largeScreenshotImage1;
  final String largeScreenshotImage2;
  final String largeScreenshotImage3;
  final List<CastEntity> cast;
  final String dateUploaded;

  const MovieDetailsEntity({
    required this.id,
    required this.url,
    required this.imdbCode,
    required this.title,
    required this.titleEnglish,
    this.titleLong,
    required this.year,
    required this.rating,
    required this.runtime,
    required this.genres,
    required this.likeCount,
    required this.descriptionIntro,
    required this.descriptionFull,
    this.ytTrailerCode,
    required this.language,
    this.mpaRating,
    required this.backgroundImage,
    required this.backgroundImageOriginal,
    required this.smallCoverImage,
    required this.mediumCoverImage,
    required this.largeCoverImage,
    required this.mediumScreenshotImage1,
    required this.mediumScreenshotImage2,
    required this.mediumScreenshotImage3,
    required this.largeScreenshotImage1,
    required this.largeScreenshotImage2,
    required this.largeScreenshotImage3,
    required this.cast,
    required this.dateUploaded,
  });

  // Helper getters
  String get displayTitle => titleEnglish.isNotEmpty ? titleEnglish : title;
  String get formattedRating => rating.toStringAsFixed(1);
  String get yearString => year.toString();
  String get genresString => genres.take(3).join(' • ');
  List<String> get screenshotImages => [
    largeScreenshotImage1,
    largeScreenshotImage2,
    largeScreenshotImage3,
  ];
}