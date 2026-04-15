// lib/data/movie/response/response_api.dart

/// status : "ok"
/// status_message : "Query was successful"
/// data : {"movie_count":74421,"limit":20,"page_number":1,"movies":[]}
/// @meta : {"api_version":2,"execution_time":"0 ms"}

class ResponseApi {
  String? status;
  String? statusMessage;
  Data? data;
  Meta? meta;

  ResponseApi({
    this.status,
    this.statusMessage,
    this.data,
    this.meta,
  });

  ResponseApi.fromJson(Map<String, dynamic> json) {
    status = json['status'] as String?;
    statusMessage = json['status_message'] as String?;
    data = json['data'] != null ? Data.fromJson(json['data'] as Map<String, dynamic>) : null;
    meta = json['@meta'] != null ? Meta.fromJson(json['@meta'] as Map<String, dynamic>) : null;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['status_message'] = statusMessage;
    if (data != null) {
      map['data'] = data?.toJson();
    }
    if (meta != null) {
      map['@meta'] = meta?.toJson();
    }
    return map;
  }
}

/// api_version : 2
/// execution_time : "0 ms"

class Meta {
  num? apiVersion;
  String? executionTime;

  Meta({
    this.apiVersion,
    this.executionTime,
  });

  Meta.fromJson(Map<String, dynamic> json) {
    apiVersion = json['api_version'] as num?;
    executionTime = json['execution_time'] as String?;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['api_version'] = apiVersion;
    map['execution_time'] = executionTime;
    return map;
  }
}

/// movie_count : 74421
/// limit : 20
/// page_number : 1
/// movies : []

class Data {
  num? movieCount;
  num? limit;
  num? pageNumber;
  List<Movies>? movies;

  Data({
    this.movieCount,
    this.limit,
    this.pageNumber,
    this.movies,
  });

  Data.fromJson(Map<String, dynamic> json) {
    movieCount = json['movie_count'] as num?;
    limit = json['limit'] as num?;
    pageNumber = json['page_number'] as num?;
    if (json['movies'] != null) {
      movies = [];
      (json['movies'] as List).forEach((v) {
        movies?.add(Movies.fromJson(v as Map<String, dynamic>));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['movie_count'] = movieCount;
    map['limit'] = limit;
    map['page_number'] = pageNumber;
    if (movies != null) {
      map['movies'] = movies?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// id : 75714
/// url : "https://yts.bz/movies/undertone-2025"
/// imdb_code : "tt35892608"
/// title : "Undertone"
/// title_english : "Undertone"
/// title_long : "Undertone (2025)"
/// slug : "undertone-2025"
/// year : 2025
/// rating : 6.2
/// runtime : 94
/// genres : ["Action","Horror","Sci-Fi","Thriller"]
/// summary : "The host of a popular paranormal podcast becomes haunted by terrifying recordings mysteriously sent her way."
/// description_full : "The host of a popular paranormal podcast becomes haunted by terrifying recordings mysteriously sent her way."
/// synopsis : "The host of a popular paranormal podcast becomes haunted by terrifying recordings mysteriously sent her way."
/// yt_trailer_code : "1fCZhJMkBaY"
/// language : "en"
/// mpa_rating : "R"
/// background_image : "https://yts.bz/assets/images/movies/undertone_2025/background.jpg"
/// background_image_original : "https://yts.bz/assets/images/movies/undertone_2025/background.jpg"
/// small_cover_image : "https://yts.bz/assets/images/movies/undertone_2025/small-cover.jpg"
/// medium_cover_image : "https://yts.bz/assets/images/movies/undertone_2025/medium-cover.jpg"
/// large_cover_image : "https://yts.bz/assets/images/movies/undertone_2025/large-cover.jpg"
/// state : "ok"
/// torrents : []
/// date_uploaded : "2026-04-14 18:35:26"
/// date_uploaded_unix : 1776184526

class Movies {
  num? id;
  String? url;
  String? imdbCode;
  String? title;
  String? titleEnglish;
  String? titleLong;
  String? slug;
  num? year;
  num? rating;
  num? runtime;
  List<String>? genres;
  String? summary;
  String? descriptionFull;
  String? synopsis;
  String? ytTrailerCode;
  String? language;
  String? mpaRating;
  String? backgroundImage;
  String? backgroundImageOriginal;
  String? smallCoverImage;
  String? mediumCoverImage;
  String? largeCoverImage;
  String? state;
  List<Torrents>? torrents;
  String? dateUploaded;
  num? dateUploadedUnix;

  Movies({
    this.id,
    this.url,
    this.imdbCode,
    this.title,
    this.titleEnglish,
    this.titleLong,
    this.slug,
    this.year,
    this.rating,
    this.runtime,
    this.genres,
    this.summary,
    this.descriptionFull,
    this.synopsis,
    this.ytTrailerCode,
    this.language,
    this.mpaRating,
    this.backgroundImage,
    this.backgroundImageOriginal,
    this.smallCoverImage,
    this.mediumCoverImage,
    this.largeCoverImage,
    this.state,
    this.torrents,
    this.dateUploaded,
    this.dateUploadedUnix,
  });

  Movies.fromJson(Map<String, dynamic> json) {
    id = json['id'] as num?;
    url = json['url'] as String?;
    imdbCode = json['imdb_code'] as String?;
    title = json['title'] as String?;
    titleEnglish = json['title_english'] as String?;
    titleLong = json['title_long'] as String?;
    slug = json['slug'] as String?;
    year = json['year'] as num?;
    rating = json['rating'] as num?;
    runtime = json['runtime'] as num?;
    genres = (json['genres'] as List?)?.cast<String>();
    summary = json['summary'] as String?;
    descriptionFull = json['description_full'] as String?;
    synopsis = json['synopsis'] as String?;
    ytTrailerCode = json['yt_trailer_code'] as String?;
    language = json['language'] as String?;
    mpaRating = json['mpa_rating'] as String?;
    backgroundImage = json['background_image'] as String?;
    backgroundImageOriginal = json['background_image_original'] as String?;
    smallCoverImage = json['small_cover_image'] as String?;
    mediumCoverImage = json['medium_cover_image'] as String?;
    largeCoverImage = json['large_cover_image'] as String?;
    state = json['state'] as String?;
    if (json['torrents'] != null) {
      torrents = [];
      (json['torrents'] as List).forEach((v) {
        torrents?.add(Torrents.fromJson(v as Map<String, dynamic>));
      });
    }
    dateUploaded = json['date_uploaded'] as String?;
    dateUploadedUnix = json['date_uploaded_unix'] as num?;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['url'] = url;
    map['imdb_code'] = imdbCode;
    map['title'] = title;
    map['title_english'] = titleEnglish;
    map['title_long'] = titleLong;
    map['slug'] = slug;
    map['year'] = year;
    map['rating'] = rating;
    map['runtime'] = runtime;
    map['genres'] = genres;
    map['summary'] = summary;
    map['description_full'] = descriptionFull;
    map['synopsis'] = synopsis;
    map['yt_trailer_code'] = ytTrailerCode;
    map['language'] = language;
    map['mpa_rating'] = mpaRating;
    map['background_image'] = backgroundImage;
    map['background_image_original'] = backgroundImageOriginal;
    map['small_cover_image'] = smallCoverImage;
    map['medium_cover_image'] = mediumCoverImage;
    map['large_cover_image'] = largeCoverImage;
    map['state'] = state;
    if (torrents != null) {
      map['torrents'] = torrents?.map((v) => v.toJson()).toList();
    }
    map['date_uploaded'] = dateUploaded;
    map['date_uploaded_unix'] = dateUploadedUnix;
    return map;
  }
}

/// url : "https://yts.bz/torrent/download/0A8EBA7C5F0EFC2B2CC54DF5416DE7FADE01B10A"
/// hash : "0A8EBA7C5F0EFC2B2CC54DF5416DE7FADE01B10A"
/// quality : "720p"
/// type : "web"
/// is_repack : "0"
/// video_codec : "x264"
/// bit_depth : "8"
/// audio_channels : "2.0"
/// seeds : 100
/// peers : 100
/// size : "864.73 MB"
/// size_bytes : 906735124
/// date_uploaded : "2026-04-14 18:35:26"
/// date_uploaded_unix : 1776184526

class Torrents {
  String? url;
  String? hash;
  String? quality;
  String? type;
  String? isRepack;
  String? videoCodec;
  String? bitDepth;
  String? audioChannels;
  num? seeds;
  num? peers;
  String? size;
  num? sizeBytes;
  String? dateUploaded;
  num? dateUploadedUnix;

  Torrents({
    this.url,
    this.hash,
    this.quality,
    this.type,
    this.isRepack,
    this.videoCodec,
    this.bitDepth,
    this.audioChannels,
    this.seeds,
    this.peers,
    this.size,
    this.sizeBytes,
    this.dateUploaded,
    this.dateUploadedUnix,
  });

  Torrents.fromJson(Map<String, dynamic> json) {
    url = json['url'] as String?;
    hash = json['hash'] as String?;
    quality = json['quality'] as String?;
    type = json['type'] as String?;
    isRepack = json['is_repack'] as String?;
    videoCodec = json['video_codec'] as String?;
    bitDepth = json['bit_depth'] as String?;
    audioChannels = json['audio_channels'] as String?;
    seeds = json['seeds'] as num?;
    peers = json['peers'] as num?;
    size = json['size'] as String?;
    sizeBytes = json['size_bytes'] as num?;
    dateUploaded = json['date_uploaded'] as String?;
    dateUploadedUnix = json['date_uploaded_unix'] as num?;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['url'] = url;
    map['hash'] = hash;
    map['quality'] = quality;
    map['type'] = type;
    map['is_repack'] = isRepack;
    map['video_codec'] = videoCodec;
    map['bit_depth'] = bitDepth;
    map['audio_channels'] = audioChannels;
    map['seeds'] = seeds;
    map['peers'] = peers;
    map['size'] = size;
    map['size_bytes'] = sizeBytes;
    map['date_uploaded'] = dateUploaded;
    map['date_uploaded_unix'] = dateUploadedUnix;
    return map;
  }
}