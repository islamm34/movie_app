// lib/data/movie_details/response/api_responsed.dart

/// status : "ok"
/// status_message : "Query was successful"
/// data : {"movie":{"id":15,"url":"https://yts.bz/movies/16-blocks-2006","imdb_code":"tt0450232","title":"16 Blocks","title_english":"16 Blocks","title_long":"16 Blocks (2006)","slug":"16-blocks-2006","year":2006,"rating":6.6,"runtime":102,"genres":["Action","Crime","Drama","Thriller"],"like_count":56,"description_intro":"An aging alcoholic cop is assigned the task of escorting a witness from police custody to a courthouse 16 blocks away. There are, however, chaotic forces at work that prevent them from making it in one piece.","description_full":"An aging alcoholic cop is assigned the task of escorting a witness from police custody to a courthouse 16 blocks away. There are, however, chaotic forces at work that prevent them from making it in one piece.","yt_trailer_code":"55nKvGV0APA","language":"en","mpa_rating":"PG-13","background_image":"https://yts.bz/assets/images/movies/16_Blocks_2006/background.jpg","background_image_original":"https://yts.bz/assets/images/movies/16_Blocks_2006/background.jpg","small_cover_image":"https://yts.bz/assets/images/movies/16_Blocks_2006/small-cover.jpg","medium_cover_image":"https://yts.bz/assets/images/movies/16_Blocks_2006/medium-cover.jpg","large_cover_image":"https://yts.bz/assets/images/movies/16_Blocks_2006/large-cover.jpg","medium_screenshot_image1":"https://yts.bz/assets/images/movies/16_Blocks_2006/medium-screenshot1.jpg","medium_screenshot_image2":"https://yts.bz/assets/images/movies/16_Blocks_2006/medium-screenshot2.jpg","medium_screenshot_image3":"https://yts.bz/assets/images/movies/16_Blocks_2006/medium-screenshot3.jpg","large_screenshot_image1":"https://yts.bz/assets/images/movies/16_Blocks_2006/large-screenshot1.jpg","large_screenshot_image2":"https://yts.bz/assets/images/movies/16_Blocks_2006/large-screenshot2.jpg","large_screenshot_image3":"https://yts.bz/assets/images/movies/16_Blocks_2006/large-screenshot3.jpg","cast":[{"name":"Bruce Willis","character_name":"Det. Jack Mosley","url_small_image":"https://yts.bz/assets/images/actors/thumb/nm0000246.jpg","imdb_code":"0000246"},{"name":"Spencer Kayden","character_name":"Juror","url_small_image":"https://yts.bz/assets/images/actors/thumb/nm0443248.jpg","imdb_code":"0443248"},{"name":"Tig Fong","character_name":"Briggs","url_small_image":"https://yts.bz/assets/images/actors/thumb/nm0284609.jpg","imdb_code":"0284609"},{"name":"Alan Lee","character_name":"Subway Commuter / Pedestrian","url_small_image":"https://yts.bz/assets/images/actors/thumb/nm2265907.jpg","imdb_code":"2265907"}],"torrents":[{"url":"https://yts.bz/torrent/download/8619B57A3F39F1B49A1A698EA5400A883928C0A2","hash":"8619B57A3F39F1B49A1A698EA5400A883928C0A2","quality":"720p","type":"bluray","is_repack":"0","video_codec":"x264","bit_depth":"8","audio_channels":"2.0","seeds":0,"peers":1,"size":"702.04 MB","size_bytes":736142295,"date_uploaded":"2015-10-31 20:47:35","date_uploaded_unix":1446320855},{"url":"https://yts.bz/torrent/download/2A4B9A41C92A20A06C8846E66AD9B5BC4B669BC6","hash":"2A4B9A41C92A20A06C8846E66AD9B5BC4B669BC6","quality":"1080p","type":"bluray","is_repack":"0","video_codec":"x264","bit_depth":"8","audio_channels":"2.0","seeds":21,"peers":0,"size":"1.40 GB","size_bytes":1503238554,"date_uploaded":"2015-10-31 20:47:38","date_uploaded_unix":1446320858}],"date_uploaded":"2015-10-31 20:47:35","date_uploaded_unix":1446320855}}
/// @meta : {"api_version":2,"execution_time":"0 ms"}

class ApiResponsed {
  String? status;
  String? statusMessage;
  Data? data;
  Meta? meta;

  ApiResponsed({
    this.status,
    this.statusMessage,
    this.data,
    this.meta,
  });

  ApiResponsed.fromJson(Map<String, dynamic> json) {
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

/// movie : {}

class Data {
  Movie? movie;

  Data({
    this.movie,
  });

  Data.fromJson(Map<String, dynamic> json) {
    movie = json['movie'] != null ? Movie.fromJson(json['movie'] as Map<String, dynamic>) : null;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (movie != null) {
      map['movie'] = movie?.toJson();
    }
    return map;
  }
}

/// id : 15
/// url : "https://yts.bz/movies/16-blocks-2006"
/// imdb_code : "tt0450232"
/// title : "16 Blocks"
/// title_english : "16 Blocks"
/// title_long : "16 Blocks (2006)"
/// slug : "16-blocks-2006"
/// year : 2006
/// rating : 6.6
/// runtime : 102
/// genres : ["Action","Crime","Drama","Thriller"]
/// like_count : 56
/// description_intro : "An aging alcoholic cop is assigned the task of escorting a witness from police custody to a courthouse 16 blocks away. There are, however, chaotic forces at work that prevent them from making it in one piece."
/// description_full : "An aging alcoholic cop is assigned the task of escorting a witness from police custody to a courthouse 16 blocks away. There are, however, chaotic forces at work that prevent them from making it in one piece."
/// yt_trailer_code : "55nKvGV0APA"
/// language : "en"
/// mpa_rating : "PG-13"
/// background_image : "https://yts.bz/assets/images/movies/16_Blocks_2006/background.jpg"
/// background_image_original : "https://yts.bz/assets/images/movies/16_Blocks_2006/background.jpg"
/// small_cover_image : "https://yts.bz/assets/images/movies/16_Blocks_2006/small-cover.jpg"
/// medium_cover_image : "https://yts.bz/assets/images/movies/16_Blocks_2006/medium-cover.jpg"
/// large_cover_image : "https://yts.bz/assets/images/movies/16_Blocks_2006/large-cover.jpg"
/// medium_screenshot_image1 : "https://yts.bz/assets/images/movies/16_Blocks_2006/medium-screenshot1.jpg"
/// medium_screenshot_image2 : "https://yts.bz/assets/images/movies/16_Blocks_2006/medium-screenshot2.jpg"
/// medium_screenshot_image3 : "https://yts.bz/assets/images/movies/16_Blocks_2006/medium-screenshot3.jpg"
/// large_screenshot_image1 : "https://yts.bz/assets/images/movies/16_Blocks_2006/large-screenshot1.jpg"
/// large_screenshot_image2 : "https://yts.bz/assets/images/movies/16_Blocks_2006/large-screenshot2.jpg"
/// large_screenshot_image3 : "https://yts.bz/assets/images/movies/16_Blocks_2006/large-screenshot3.jpg"
/// cast : []
/// torrents : []
/// date_uploaded : "2015-10-31 20:47:35"
/// date_uploaded_unix : 1446320855

class Movie {
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
  num? likeCount;
  String? descriptionIntro;
  String? descriptionFull;
  String? ytTrailerCode;
  String? language;
  String? mpaRating;
  String? backgroundImage;
  String? backgroundImageOriginal;
  String? smallCoverImage;
  String? mediumCoverImage;
  String? largeCoverImage;
  String? mediumScreenshotImage1;
  String? mediumScreenshotImage2;
  String? mediumScreenshotImage3;
  String? largeScreenshotImage1;
  String? largeScreenshotImage2;
  String? largeScreenshotImage3;
  List<Cast>? cast;
  List<Torrents>? torrents;
  String? dateUploaded;
  num? dateUploadedUnix;

  Movie({
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
    this.likeCount,
    this.descriptionIntro,
    this.descriptionFull,
    this.ytTrailerCode,
    this.language,
    this.mpaRating,
    this.backgroundImage,
    this.backgroundImageOriginal,
    this.smallCoverImage,
    this.mediumCoverImage,
    this.largeCoverImage,
    this.mediumScreenshotImage1,
    this.mediumScreenshotImage2,
    this.mediumScreenshotImage3,
    this.largeScreenshotImage1,
    this.largeScreenshotImage2,
    this.largeScreenshotImage3,
    this.cast,
    this.torrents,
    this.dateUploaded,
    this.dateUploadedUnix,
  });

  Movie.fromJson(Map<String, dynamic> json) {
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
    likeCount = json['like_count'] as num?;
    descriptionIntro = json['description_intro'] as String?;
    descriptionFull = json['description_full'] as String?;
    ytTrailerCode = json['yt_trailer_code'] as String?;
    language = json['language'] as String?;
    mpaRating = json['mpa_rating'] as String?;
    backgroundImage = json['background_image'] as String?;
    backgroundImageOriginal = json['background_image_original'] as String?;
    smallCoverImage = json['small_cover_image'] as String?;
    mediumCoverImage = json['medium_cover_image'] as String?;
    largeCoverImage = json['large_cover_image'] as String?;
    mediumScreenshotImage1 = json['medium_screenshot_image1'] as String?;
    mediumScreenshotImage2 = json['medium_screenshot_image2'] as String?;
    mediumScreenshotImage3 = json['medium_screenshot_image3'] as String?;
    largeScreenshotImage1 = json['large_screenshot_image1'] as String?;
    largeScreenshotImage2 = json['large_screenshot_image2'] as String?;
    largeScreenshotImage3 = json['large_screenshot_image3'] as String?;
    if (json['cast'] != null) {
      cast = [];
      (json['cast'] as List).forEach((v) {
        cast?.add(Cast.fromJson(v as Map<String, dynamic>));
      });
    }
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
    map['like_count'] = likeCount;
    map['description_intro'] = descriptionIntro;
    map['description_full'] = descriptionFull;
    map['yt_trailer_code'] = ytTrailerCode;
    map['language'] = language;
    map['mpa_rating'] = mpaRating;
    map['background_image'] = backgroundImage;
    map['background_image_original'] = backgroundImageOriginal;
    map['small_cover_image'] = smallCoverImage;
    map['medium_cover_image'] = mediumCoverImage;
    map['large_cover_image'] = largeCoverImage;
    map['medium_screenshot_image1'] = mediumScreenshotImage1;
    map['medium_screenshot_image2'] = mediumScreenshotImage2;
    map['medium_screenshot_image3'] = mediumScreenshotImage3;
    map['large_screenshot_image1'] = largeScreenshotImage1;
    map['large_screenshot_image2'] = largeScreenshotImage2;
    map['large_screenshot_image3'] = largeScreenshotImage3;
    if (cast != null) {
      map['cast'] = cast?.map((v) => v.toJson()).toList();
    }
    if (torrents != null) {
      map['torrents'] = torrents?.map((v) => v.toJson()).toList();
    }
    map['date_uploaded'] = dateUploaded;
    map['date_uploaded_unix'] = dateUploadedUnix;
    return map;
  }
}

/// url : "https://yts.bz/torrent/download/8619B57A3F39F1B49A1A698EA5400A883928C0A2"
/// hash : "8619B57A3F39F1B49A1A698EA5400A883928C0A2"
/// quality : "720p"
/// type : "bluray"
/// is_repack : "0"
/// video_codec : "x264"
/// bit_depth : "8"
/// audio_channels : "2.0"
/// seeds : 0
/// peers : 1
/// size : "702.04 MB"
/// size_bytes : 736142295
/// date_uploaded : "2015-10-31 20:47:35"
/// date_uploaded_unix : 1446320855

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

/// name : "Bruce Willis"
/// character_name : "Det. Jack Mosley"
/// url_small_image : "https://yts.bz/assets/images/actors/thumb/nm0000246.jpg"
/// imdb_code : "0000246"

class Cast {
  String? name;
  String? characterName;
  String? urlSmallImage;
  String? imdbCode;

  Cast({
    this.name,
    this.characterName,
    this.urlSmallImage,
    this.imdbCode,
  });

  Cast.fromJson(Map<String, dynamic> json) {
    name = json['name'] as String?;
    characterName = json['character_name'] as String?;
    urlSmallImage = json['url_small_image'] as String?;
    imdbCode = json['imdb_code'] as String?;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['character_name'] = characterName;
    map['url_small_image'] = urlSmallImage;
    map['imdb_code'] = imdbCode;
    return map;
  }
}