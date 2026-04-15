// lib/features/ui/home/home_screen.dart

import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:movie_app/features/ui/home/ui/tab_bar/explore/explore_screen.dart';
import 'package:movie_app/features/ui/home/ui/tab_bar/profile/profile_screen.dart';
import 'package:movie_app/features/ui/home/ui/tab_bar/search/search_screen.dart';
import 'package:movie_app/features/ui/movie_details/ui/movie_details_screen.dart';
import '../data_model/data_source/movie_data_source.dart';
import '../domain/movie_entity.dart';
import '../repository/repository_impl/movie_repository_impl.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/usecase/get_movies_usecase.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeContentScreen(),
    const SearchScreen(),
    const ExploreScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121312),
      body: Stack(
        children: [
          Positioned.fill(child: Container(color: Colors.transparent)),
          SafeArea(
            child: Column(
              children: [
                Expanded(child: _screens[_currentIndex]),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: BottomNavBar(
                    currentIndex: _currentIndex,
                    onTap: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeContentScreen extends StatefulWidget {
  const HomeContentScreen({super.key});

  @override
  State<HomeContentScreen> createState() => _HomeContentScreenState();
}

class _HomeContentScreenState extends State<HomeContentScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  List<MovieEntity> _movies = [];
  bool _isLoading = true;
  String _errorMessage = '';
  Timer? _autoScrollTimer;

  final GetMoviesUseCase _getMoviesUseCase = GetMoviesUseCase(
    MovieRepositoryImpl(dataSource: MovieDataSource()),
  );

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.7);
    _loadMovies();
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadMovies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final movies = await _getMoviesUseCase.execute(limit: 100);
      setState(() {
        _movies = movies;
        _isLoading = false;
      });

      if (_movies.isNotEmpty) {
        _startAutoScroll();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients && _movies.isNotEmpty) {
        int nextPage = _currentPage + 1;
        if (nextPage >= _movies.length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
  }

  void _resetAutoScroll() {
    _stopAutoScroll();
    _startAutoScroll();
  }

  void _navigateToMovieDetails(MovieEntity movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailsScreen(movie: movie),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFF6BD00)),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMovies,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF6BD00),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_movies.isEmpty) {
      return const Center(
        child: Text(
          'No movies available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Stack(
      children: [
        // Background image with blur
        Positioned.fill(
          child: Image.network(
            _movies[_currentPage].backgroundImage,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: Colors.grey[800]);
            },
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
        ),
        // Main content
        SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Available Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 400,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _movies.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                        _resetAutoScroll();
                      },
                      itemBuilder: (context, index) {
                        final isCenter = index == _currentPage;
                        final movie = _movies[index];
                        return GestureDetector(
                          onTap: () => _navigateToMovieDetails(movie),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: isCenter ? 0 : 20,
                            ),
                            height: isCenter ? 430 : 350,
                            width: isCenter ? 300 : 260,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: isCenter ? 20 : 10,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: _buildMovieCard(movie, isCenter),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Recommended for You',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _movies.length,
                      itemBuilder: (context, index) {
                        final movie = _movies[index];
                        return GestureDetector(
                          onTap: () => _navigateToMovieDetails(movie),
                          child: Container(
                            width: 120,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: NetworkImage(movie.mediumCoverImage),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Popular Movies',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _movies.length,
                      itemBuilder: (context, index) {
                        final movie = _movies[index];
                        return GestureDetector(
                          onTap: () => _navigateToMovieDetails(movie),
                          child: Container(
                            width: 120,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: NetworkImage(movie.mediumCoverImage),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMovieCard(MovieEntity movie, bool isCenter) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            movie.largeCoverImage,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[800],
                child: const Center(
                  child: Icon(Icons.movie, size: 60, color: Colors.white54),
                ),
              );
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: isCenter ? 120 : 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Color(0xFFF6BD00), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    movie.formattedRating,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isCenter)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.titleEnglish.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    movie.genresString,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}