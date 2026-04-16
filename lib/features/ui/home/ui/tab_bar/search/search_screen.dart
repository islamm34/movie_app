// lib/features/ui/home/ui/tab_bar/search/search_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../../core/utilities/aap_assets.dart';
import '../../../../movie_details/ui/movie_details_screen.dart';
import '../../../data_model/data_source/movie_data_source.dart';
import '../../../domain/movie_entity.dart';
import '../../../repository/repository_impl/movie_repository_impl.dart';
import '../../../widgets/usecase/get_movies_usecase.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<MovieEntity> _searchResults = [];
  List<MovieEntity> _allMovies = [];
  List<Map<String, dynamic>> _recentMovies = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String? _currentUserId;

  final GetMoviesUseCase _getMoviesUseCase = GetMoviesUseCase(
    MovieRepositoryImpl(dataSource: MovieDataSource()),
  );

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _currentUserId = user?.uid ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';
    });
    await _loadInitialMovies();
    await _loadRecentMovies();
  }

  String _getUserStorageKey() {
    // مفتاح فريد لكل مستخدم
    return 'recent_movies_${_currentUserId ?? "guest"}';
  }

  Future<void> _loadRecentMovies() async {
    if (_currentUserId == null) return;

    final prefs = await SharedPreferences.getInstance();
    final recentMoviesJson = prefs.getStringList(_getUserStorageKey()) ?? [];

    // تأكد من أن القائمة خاصة بالمستخدم الحالي فقط
    setState(() {
      _recentMovies = recentMoviesJson.map((json) {
        final parts = json.split('|||');
        return {
          'id': int.parse(parts[0]),
          'title': parts[1],
          'rating': parts[2],
          'imageUrl': parts[3],
          'year': parts[4],
        };
      }).toList();
    });
  }

  Future<void> _saveRecentMovie(MovieEntity movie) async {
    if (_currentUserId == null) return;

    final prefs = await SharedPreferences.getInstance();
    final storageKey = _getUserStorageKey();
    List<String> recentMoviesJson = prefs.getStringList(storageKey) ?? [];

    final movieKey = '${movie.id}|||${movie.titleEnglish}|||${movie.formattedRating}|||${movie.mediumCoverImage}|||${movie.year}';

    // إزالة إذا كان موجوداً مسبقاً
    recentMoviesJson.remove(movieKey);
    // إضافة في البداية
    recentMoviesJson.insert(0, movieKey);
    // الاحتفاظ بآخر 10 أفلام فقط
    if (recentMoviesJson.length > 10) {
      recentMoviesJson = recentMoviesJson.take(10).toList();
    }

    await prefs.setStringList(storageKey, recentMoviesJson);

    final updatedMovies = recentMoviesJson.map((json) {
      final parts = json.split('|||');
      return {
        'id': int.parse(parts[0]),
        'title': parts[1],
        'rating': parts[2],
        'imageUrl': parts[3],
        'year': parts[4],
      };
    }).toList();

    setState(() {
      _recentMovies = updatedMovies;
    });
  }

  Future<void> _clearRecentMovies() async {
    if (_currentUserId == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_getUserStorageKey());
    setState(() {
      _recentMovies = [];
    });
  }

  Future<void> _removeRecentMovie(int index) async {
    if (_currentUserId == null) return;

    final prefs = await SharedPreferences.getInstance();
    final storageKey = _getUserStorageKey();
    List<String> recentMoviesJson = prefs.getStringList(storageKey) ?? [];

    if (index < recentMoviesJson.length) {
      recentMoviesJson.removeAt(index);
      await prefs.setStringList(storageKey, recentMoviesJson);

      final updatedMovies = recentMoviesJson.map((json) {
        final parts = json.split('|||');
        return {
          'id': int.parse(parts[0]),
          'title': parts[1],
          'rating': parts[2],
          'imageUrl': parts[3],
          'year': parts[4],
        };
      }).toList();

      setState(() {
        _recentMovies = updatedMovies;
      });
    }
  }

  Future<void> _loadInitialMovies() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final movies = await _getMoviesUseCase.execute(limit: 20);
      setState(() {
        _allMovies = movies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _searchMovies(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = _allMovies
            .where(
              (movie) =>
          movie.title.toLowerCase().contains(query.toLowerCase()) ||
              movie.titleEnglish.toLowerCase().contains(
                query.toLowerCase(),
              ),
        )
            .toList();
      }
    });
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;
    _searchController.text = query;
    _searchMovies(query);
    _focusNode.unfocus();
  }

  void _navigateToMovieDetails(MovieEntity movie) async {
    await _saveRecentMovie(movie);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailsScreen(movieId: movie.id),
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _searchResults = [];
    });
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121312),
      body: SafeArea(
        child: Column(
          children: [
            // ==================== Search Text Field ====================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 21),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF282A28),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  onChanged: _searchMovies,
                  onSubmitted: _performSearch,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      color: Colors.white54,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SvgPicture.asset(
                        AppAssets.searchSvg,
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    suffixIcon: _isSearching
                        ? IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white54,
                        size: 20,
                      ),
                      onPressed: _clearSearch,
                    )
                        : null,
                  ),
                ),
              ),
            ),

            // ==================== Results Section ====================
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFF6BD00)),
      );
    }

    if (_isSearching && _searchResults.isEmpty) {
      return _buildEmptyState();
    }

    if (_isSearching && _searchResults.isNotEmpty) {
      return _buildResultsGrid();
    }

    if (_recentMovies.isNotEmpty) {
      return _buildRecentMovies();
    }

    return _buildInitialState();
  }

  Widget _buildInitialState() {
    return Center(
      child: Image.asset(
        AppAssets.Empty1,
        width: 200,
        height: 200,
        color: Colors.amber,
      ),
    );
  }

  Widget _buildRecentMovies() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recently Viewed',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: _clearRecentMovies,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Clear All',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    color: Color(0xFFF6BD00),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _recentMovies.length,
            itemBuilder: (context, index) {
              final movie = _recentMovies[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    movie['imageUrl'],
                    width: 50,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 50,
                        height: 70,
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.movie,
                          color: Colors.white54,
                          size: 30,
                        ),
                      );
                    },
                  ),
                ),
                title: Text(
                  movie['title'],
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                subtitle: Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFF6BD00), size: 12),
                    const SizedBox(width: 4),
                    Text(
                      movie['rating'],
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white54,
                    size: 18,
                  ),
                  onPressed: () => _removeRecentMovie(index),
                ),
                onTap: () {
                  final movieEntity = _allMovies.firstWhere(
                        (m) => m.id == movie['id'],
                    orElse: () => _allMovies.first,
                  );
                  _navigateToMovieDetails(movieEntity);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            AppAssets.search_empty,
            width: 124,
            height: 124,
            colorFilter: const ColorFilter.mode(
              Colors.amber,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No results found',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching for something else',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              color: Colors.white38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.68,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final movie = _searchResults[index];
        return _buildMovieCard(movie);
      },
    );
  }

  Widget _buildMovieCard(MovieEntity movie) {
    return GestureDetector(
      onTap: () => _navigateToMovieDetails(movie),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Image.network(
                movie.largeCoverImage,
                height: 280,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 280,
                    width: double.infinity,
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.movie,
                      color: Colors.white54,
                      size: 50,
                    ),
                  );
                },
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        color: Color(0xFFF6BD00),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        movie.formattedRating,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}