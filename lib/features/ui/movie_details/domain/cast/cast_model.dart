// lib/data/movie_details/models/cast_model.dart


import '../../api_responsed/api_responsed.dart';
import 'cast_entity.dart';

class CastModel extends CastEntity {
  const CastModel({
    required super.name,
    required super.characterName,
    required super.urlSmallImage,
    required super.imdbCode,
  });

  // Convert from API response (Cast object)
  factory CastModel.fromCast(Cast cast) {
    return CastModel(
      name: cast.name ?? '',
      characterName: cast.characterName ?? '',
      urlSmallImage: cast.urlSmallImage ?? '',
      imdbCode: cast.imdbCode ?? '',
    );
  }

  // Convert from JSON
  factory CastModel.fromJson(Map<String, dynamic> json) {
    return CastModel(
      name: json['name'] as String? ?? '',
      characterName: json['characterName'] as String? ?? '',
      urlSmallImage: json['urlSmallImage'] as String? ?? '',
      imdbCode: json['imdbCode'] as String? ?? '',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'characterName': characterName,
      'urlSmallImage': urlSmallImage,
      'imdbCode': imdbCode,
    };
  }
}