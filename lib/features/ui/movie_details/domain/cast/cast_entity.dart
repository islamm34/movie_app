// lib/domain/movie_details/entities/cast_entity.dart

class CastEntity {
  final String name;
  final String characterName;
  final String urlSmallImage;
  final String imdbCode;

  const CastEntity({
    required this.name,
    required this.characterName,
    required this.urlSmallImage,
    required this.imdbCode,
  });
}