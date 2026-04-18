import 'package:flutter/material.dart';
import '../../../../movie_details/ui/movie_details_screen.dart';
import '../../../data_model/data_source/movie_data_source.dart';
import '../../../domain/movie_entity.dart';
import '../../../repository/repository_impl/movie_repository_impl.dart';
import '../../../widgets/usecase/get_movies_usecase.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<MovieEntity> _movies = [];
  List<String> _selectedGenres = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _limit = 20;
  final ScrollController _scrollController = ScrollController();

  final List<String> _allGenres = [
    'Action',
    'Adventure',
    'Animation',
    'Comedy',
    'Crime',
    'Documentary',
    'Drama',
    'Family',
    'Fantasy',
    'Horror',
    'Mystery',
    'Romance',
    'Sci-Fi',
    'Thriller',
  ];

  final GetMoviesUseCase _getMoviesUseCase = GetMoviesUseCase(
    MovieRepositoryImpl(dataSource: MovieDataSource()),
  );

  @override
  void initState() {
    super.initState();
    _loadMovies();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadMoreMovies();
      }
    }
  }

  Future<void> _loadMovies() async {
    setState(() {
      _isLoading = true;
      _movies = [];
      _currentPage = 1;
      _hasMore = true;
    });

    try {
      final movies = await _getMoviesUseCase.execute(
        page: _currentPage,
        limit: _limit,
        genre: _selectedGenres.isNotEmpty ? _selectedGenres.first : null,
        sortBy: 'date_added',
        fetchAll: false, // ✅ استخدام Pagination
      );

      setState(() {
        _movies = movies;
        _isLoading = false;
        _hasMore = movies.length == _limit;
      });

      if (movies.isNotEmpty) {
        _currentPage++;
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreMovies() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final moreMovies = await _getMoviesUseCase.execute(
        page: _currentPage,
        limit: _limit,
        genre: _selectedGenres.isNotEmpty ? _selectedGenres.first : null,
        sortBy: 'date_added',
        fetchAll: false,
      );

      setState(() {
        _movies.addAll(moreMovies);
        _isLoading = false;
        _hasMore = moreMovies.length == _limit;
      });

      if (moreMovies.isNotEmpty) {
        _currentPage++;
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _filterByGenre(String genre) async {
    setState(() {
      if (_selectedGenres.contains(genre)) {
        _selectedGenres.remove(genre);
      } else {
        _selectedGenres.add(genre);
      }
    });

    await _loadMovies(); // إعادة تحميل الصفحة الأولى
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
      body: SafeArea(
        child: Column(
          children: [
            // ==================== Header ====================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Browse',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6BD00),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_movies.length}+ Movies',
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==================== Genre Chips ====================
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _allGenres.length,
                itemBuilder: (context, index) {
                  final genre = _allGenres[index];
                  final isSelected = _selectedGenres.contains(genre);
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: FilterChip(
                      label: Text(
                        genre,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) => _filterByGenre(genre),
                      backgroundColor: const Color(0xFF282A28),
                      selectedColor: const Color(0xFFF6BD00),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // ==================== Movies Grid with Infinite Scroll ====================
            Expanded(
              child: _movies.isEmpty && _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFF6BD00),
                      ),
                    )
                  : GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.65,
                          ),
                      itemCount: _movies.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _movies.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFF6BD00),
                              ),
                            ),
                          );
                        }
                        final movie = _movies[index];
                        return _buildMovieCard(movie);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieCard(MovieEntity movie) {
    return GestureDetector(
      onTap: () => _navigateToMovieDetails(movie.id),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
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
                height: double.infinity,
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
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
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
              Positioned(
                bottom: 16,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.titleEnglish,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      movie.year.toString(),
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
