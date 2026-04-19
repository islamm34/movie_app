// lib/features/ui/movie_details/movie_details_screen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../home/domain/movie_entity.dart';
import '../../home/repository/repository_impl/movie_repository_impl.dart';
import '../../home/data_model/data_source/movie_data_source.dart';
import '../../home/widgets/usecase/get_movies_usecase.dart';
import '../data/data_source/movie_details_data_source.dart';
import '../domain/domain_entity/movie_details_entity.dart';
import '../repository/repository_impl/movie_details_repository_impl.dart';
import '../usecase/get_movie_details_usecase.dart';
class MovieDetailsScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailsScreen({
    super.key,
    required this.movieId,
  });

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  late Future<MovieDetailsEntity> _movieDetailsFuture;
  late Future<List<MovieEntity>> _similarMoviesFuture;

  final GetMovieDetailsUseCase _getMovieDetailsUseCase = GetMovieDetailsUseCase(
    MovieDetailsRepositoryImpl(dataSource: MovieDetailsDataSource()),
  );

  final GetMoviesUseCase _getMoviesUseCase = GetMoviesUseCase(
    MovieRepositoryImpl(dataSource: MovieDataSource()),
  );

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _movieDetailsFuture = _getMovieDetailsUseCase.execute(widget.movieId);
    _similarMoviesFuture = _movieDetailsFuture.then((movie) {
      final genre = movie.genres.isNotEmpty ? movie.genres.first : null;
      return _getMoviesUseCase.execute(limit: 10, genre: genre);
    });
  }

  // حفظ في Firestore
  Future<void> _addToFirestore(String collectionName, Map<String, dynamic> data) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final docRef = _firestore.collection('users').doc(userId).collection(collectionName).doc(data['id'].toString());

      if (collectionName == 'watchlist') {
        // للـ Watchlist: نضيف فقط إذا لم يكن موجود
        final doc = await docRef.get();
        if (!doc.exists) {
          await docRef.set(data);
        }
      } else {
        // للـ History: نضيف مع تحديث الوقت
        await docRef.set(data, SetOptions(merge: true));
      }

      print('✅ Saved to Firestore: $collectionName');
    } catch (e) {
      print('❌ Error saving to Firestore: $e');
    }
  }

  // حذف من Firestore
  Future<void> _removeFromFirestore(String collectionName, String movieId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      await _firestore.collection('users').doc(userId).collection(collectionName).doc(movieId).delete();
      print('✅ Removed from Firestore: $collectionName');
    } catch (e) {
      print('❌ Error removing from Firestore: $e');
    }
  }

  // التحقق من وجود الفيلم في Watchlist من Firestore
  Future<bool> _isInWatchlistFirestore(int movieId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return false;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('watchlist')
          .doc(movieId.toString())
          .get();
      return doc.exists;
    } catch (e) {
      print('❌ Error checking watchlist: $e');
      return false;
    }
  }

  // إضافة الفيلم إلى History (Firestore + SharedPreferences)
  Future<void> _addToHistory(MovieDetailsEntity movie) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    final movieData = {
      'id': movie.id,
      'title': movie.titleEnglish,
      'rating': movie.formattedRating,
      'imageUrl': movie.largeCoverImage,
      'year': movie.year,
      'watchedAt': FieldValue.serverTimestamp(),
    };

    // حفظ في Firestore (للمستخدمين المسجلين)
    if (userId != null) {
      try {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('history')
            .doc(movie.id.toString())
            .set(movieData);
        print('✅ Movie added to history in Firestore');
      } catch (e) {
        print('❌ Error saving history to Firestore: $e');
      }
    }

    // حفظ في SharedPreferences كنسخة احتياطية (للمستخدمين الضيوف)
    final prefs = await SharedPreferences.getInstance();
    final historyKey = 'history_${userId ?? 'guest'}';
    List<String> history = prefs.getStringList(historyKey) ?? [];

    final movieKey = '${movie.id}|||${movie.titleEnglish}|||${movie.formattedRating}|||${movie.largeCoverImage}|||${movie.year}';

    history.remove(movieKey);
    history.insert(0, movieKey);
    if (history.length > 20) {
      history = history.take(20).toList();
    }

    await prefs.setStringList(historyKey, history);
    print('✅ Movie added to history in SharedPreferences');
  }

  // إضافة الفيلم إلى Watchlist (Firestore + SharedPreferences)
  Future<void> _addToWatchlist(MovieDetailsEntity movie) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';

    final movieData = {
      'id': movie.id,
      'title': movie.titleEnglish,
      'rating': movie.formattedRating,
      'imageUrl': movie.largeCoverImage,
      'year': movie.year,
      'addedAt': FieldValue.serverTimestamp(),
    };

    // حفظ في Firestore (للمستخدمين المسجلين)
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      await _addToFirestore('watchlist', movieData);
    }

    // حفظ في SharedPreferences كنسخة احتياطية
    final prefs = await SharedPreferences.getInstance();
    final watchlistKey = 'watchlist_$userId';
    List<String> watchlist = prefs.getStringList(watchlistKey) ?? [];

    final movieKey = '${movie.id}|||${movie.titleEnglish}|||${movie.formattedRating}|||${movie.largeCoverImage}|||${movie.year}';

    if (!watchlist.contains(movieKey)) {
      watchlist.add(movieKey);
      await prefs.setStringList(watchlistKey, watchlist);
      _showSnackBar('Added to Watchlist', Colors.green);
    } else {
      _showSnackBar('Already in Watchlist', Colors.orange);
    }
  }

  // إزالة الفيلم من Watchlist (Firestore + SharedPreferences)
  Future<void> _removeFromWatchlist(MovieDetailsEntity movie) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';

    // حذف من Firestore
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      await _removeFromFirestore('watchlist', movie.id.toString());
    }

    // حذف من SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final watchlistKey = 'watchlist_$userId';
    List<String> watchlist = prefs.getStringList(watchlistKey) ?? [];

    watchlist.removeWhere((item) => item.startsWith('${movie.id}|||'));
    await prefs.setStringList(watchlistKey, watchlist);
    _showSnackBar('Removed from Watchlist', Colors.red);
  }

  // التحقق مما إذا كان الفيلم في Watchlist
  Future<bool> _isInWatchlist(MovieDetailsEntity movie) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';

    // التحقق من Firestore أولاً للمستخدمين المسجلين
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      return await _isInWatchlistFirestore(movie.id);
    }

    // للمستخدمين الضيوف، التحقق من SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final watchlistKey = 'watchlist_$userId';
    List<String> watchlist = prefs.getStringList(watchlistKey) ?? [];
    return watchlist.any((item) => item.startsWith('${movie.id}|||'));
  }

  Future<void> _launchMovieUrl(String url, MovieDetailsEntity movie) async {
    if (url.isEmpty) {
      _showSnackBar('No movie URL available', Colors.red);
      return;
    }

    // إضافة الفيلم إلى History
    await _addToHistory(movie);

    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      print('Error launching URL: $e');
      _showSnackBar('Could not open the movie link', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToMovieDetails(int movieId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailsScreen(movieId: movieId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121312),
      body: FutureBuilder<MovieDetailsEntity>(
        future: _movieDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFF6BD00)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _movieDetailsFuture = _getMovieDetailsUseCase.execute(widget.movieId);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF6BD00),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'No movie data available',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final movie = snapshot.data!;
          return _buildContent(movie);
        },
      ),
    );
  }

  Widget _buildContent(MovieDetailsEntity movie) {
    return Container(
      width: 430,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: Color(0xFF121312),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================== Hero Section ====================
              Stack(
                children: [
                  Container(
                    width: 430,
                    height: 645,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(movie.largeCoverImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    width: 430,
                    height: 645,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF121312).withOpacity(0.2),
                          const Color(0xFF121312),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 166,
                    top: 248,
                    child: GestureDetector(
                      onTap: () => _launchMovieUrl(movie.url, movie),
                      child: Stack(
                        children: [
                          Container(
                            width: 97,
                            height: 97,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF6BD00),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Positioned(
                            left: 5,
                            top: 5,
                            child: Container(
                              width: 87,
                              height: 87,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 10,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 28,
                            top: 28,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Color(0xFF121312),
                                size: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 112,
                    left: 28,
                    right: 28,
                    child: Text(
                      movie.titleEnglish,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        height: 1.39,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Positioned(
                    bottom: 60,
                    left: 15,
                    right: 15,
                    child: Text(
                      movie.year.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        height: 1.2,
                        color: Color(0xFFADADAD),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 16,
                    right: 16,
                    child: SizedBox(
                      width: 398,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: () => _launchMovieUrl(movie.url, movie),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE82626),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Watch',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ==================== Add to Watchlist Button ====================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FutureBuilder<bool>(
                  future: _isInWatchlist(movie),
                  builder: (context, snapshot) {
                    final isInWatchlist = snapshot.data ?? false;
                    return SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          if (isInWatchlist) {
                            await _removeFromWatchlist(movie);
                          } else {
                            await _addToWatchlist(movie);
                          }
                          setState(() {});
                        },
                        icon: Icon(
                          isInWatchlist ? Icons.check : Icons.add,
                          color: const Color(0xFFF6BD00),
                        ),
                        label: Text(
                          isInWatchlist ? 'In Watchlist' : 'Add to Watchlist',
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFF6BD00),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFF6BD00)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // ==================== Stats Row ====================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard(
                      icon: Icons.favorite,
                      value: movie.likeCount.toString(),
                      color: const Color(0xFFF6BD00),
                    ),
                    _buildStatCard(
                      icon: Icons.access_time,
                      value: '${movie.runtime} min',
                      color: const Color(0xFFF6BD00),
                    ),
                    _buildStatCard(
                      icon: Icons.star,
                      value: movie.formattedRating,
                      color: const Color(0xFFF6BD00),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ==================== Screenshots Section ====================
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  'Screen Shots',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    height: 1.39,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 9),
              _buildScreenshot(movie.largeScreenshotImage1, 167),
              const SizedBox(height: 15),
              _buildScreenshot(movie.largeScreenshotImage2, 165),
              const SizedBox(height: 15),
              _buildScreenshot(movie.largeScreenshotImage3, 166),

              const SizedBox(height: 30),

              // ==================== Similar Movies Section ====================
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  'Similar',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    height: 1.39,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<MovieEntity>>(
                future: _similarMoviesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(color: Color(0xFFF6BD00)),
                      ),
                    );
                  }

                  if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'No similar movies available',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    );
                  }

                  final similarMovies = snapshot.data!
                      .where((m) => m.id != movie.id)
                      .take(4)
                      .toList();

                  if (similarMovies.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'No similar movies available',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 16,
                      childAspectRatio: 189 / 279,
                      children: similarMovies.map((movie) {
                        return _buildSimilarMovieCard(
                          imageUrl: movie.largeCoverImage,
                          rating: movie.formattedRating,
                          title: movie.titleEnglish,
                          year: movie.year.toString(),
                          onTap: () => _navigateToMovieDetails(movie.id),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              // ==================== Summary Section ====================
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  'Summary',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    height: 1.39,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  movie.descriptionFull.isNotEmpty
                      ? movie.descriptionFull
                      : 'No summary available.',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    height: 1.39,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ==================== Cast Section ====================
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  'Cast',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    height: 1.39,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...movie.cast.map((cast) => _buildCastMember(
                imageUrl: cast.urlSmallImage ?? '',
                name: cast.name,
                character: cast.characterName ?? '',
              )).toList(),

              const SizedBox(height: 30),

              // ==================== Genres Section ====================
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  'Genres',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    height: 1.39,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: movie.genres.map((genre) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF282A28),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        genre,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScreenshot(String imageUrl, double height) {
    if (imageUrl.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          imageUrl,
          width: 398,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 398,
              height: height,
              color: Colors.grey[800],
              child: const Icon(Icons.image_not_supported, color: Colors.white54),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Container(
      width: 122,
      height: 47,
      decoration: BoxDecoration(
        color: const Color(0xFF282A28),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
              fontSize: 24,
              height: 1.2,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarMovieCard({
    required String imageUrl,
    required String rating,
    required String title,
    required String year,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              imageUrl,
              width: 189,
              height: 279,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 189,
                  height: 279,
                  color: Colors.grey[800],
                  child: const Icon(Icons.movie, color: Colors.white54),
                );
              },
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 13,
            left: 10,
            child: Container(
              width: 58,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF121312).withOpacity(0.71),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.star,
                    color: Color(0xFFF6BD00),
                    size: 15,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    rating,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      height: 1.2,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  year,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontSize: 10,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCastMember({
    required String imageUrl,
    required String name,
    required String character,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF282A28),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[800],
                    child: const Icon(Icons.person, color: Colors.white54, size: 30),
                  );
                },
              )
                  : Container(
                width: 60,
                height: 60,
                color: Colors.grey[800],
                child: const Icon(Icons.person, color: Colors.white54, size: 30),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isNotEmpty ? name : 'Unknown',
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    character.isNotEmpty ? character : 'Character',
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}