// lib/features/ui/home/domain/movie_entity.dart

class MovieEntity {
  final int id;
  final String title;
  final String titleEnglish;
  final String? titleLong;
  final int year;
  final double rating;
  final int runtime;
  final List<String> genres;
  final String summary;
  final String? descriptionFull;
  final String? ytTrailerCode;
  final String language;
  final String? mpaRating;
  final String largeCoverImage;
  final String mediumCoverImage;
  final String smallCoverImage;
  final String backgroundImage;
  final String dateUploaded;
  final String? imdbCode;  // ✅ أضف هذا الحقل
  final String? url;        // ✅ أضف هذا الحقل

  const MovieEntity({
    required this.id,
    required this.title,
    required this.titleEnglish,
    this.titleLong,
    required this.year,
    required this.rating,
    required this.runtime,
    required this.genres,
    required this.summary,
    this.descriptionFull,
    this.ytTrailerCode,
    required this.language,
    this.mpaRating,
    required this.largeCoverImage,
    required this.mediumCoverImage,
    required this.smallCoverImage,
    required this.backgroundImage,
    required this.dateUploaded,
    this.imdbCode,
    this.url,
  });

  // Helper getters
  String get displayTitle => titleEnglish.isNotEmpty ? titleEnglish : title;
  String get formattedRating => rating.toStringAsFixed(1);
  String get yearString => year.toString();
  String get genresString => genres.take(3).join(' • ');
}