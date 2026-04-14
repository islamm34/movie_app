// lib/features/ui/home/home_screen.dart

import 'dart:async';
import 'dart:ui' as ui;  // ✅ أضف هذا للـ ImageFilter
import 'package:flutter/material.dart';
import 'package:movie_app/features/ui/home/ui/tab_bar/explore/explore_screen.dart';
import 'package:movie_app/features/ui/home/ui/tab_bar/profile/profile_screen.dart';
import 'package:movie_app/features/ui/home/ui/tab_bar/search/search_screen.dart';
import '../widgets/bottom_nav_bar.dart';

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
          Positioned.fill(
            child: Container(
              color: Colors.transparent,
            ),
          ),
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
  String _currentImageUrl = 'https://picsum.photos/id/100/400/500';
  Timer? _autoScrollTimer;

  final List<Map<String, dynamic>> movies = [
    {
      'title': 'ANIEL ELGORT',
      'subtitle': 'TIME IS THE ENEMY',
      'rating': '7.7',
      'imageId': 100,
    },
    {
      'title': 'KEVIN SPACEY',
      'subtitle': 'TIME IS THE ENEMY',
      'rating': '8.2',
      'imageId': 101,
    },
    {
      'title': 'LEXI JAMES',
      'subtitle': 'TIME IS THE ENEMY',
      'rating': '6.9',
      'imageId': 102,
    },
    {
      'title': 'ELIZA GONZALEZ',
      'subtitle': 'TIME IS THE ENEMY',
      'rating': '7.5',
      'imageId': 103,
    },
    {
      'title': 'JOHN HAMM',
      'subtitle': 'TIME IS THE ENEMY',
      'rating': '8.0',
      'imageId': 104,
    },
  ];

  final List<int> validImageIds = [
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
    11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.7);
    _startAutoScroll();
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        int nextPage = _currentPage + 1;
        if (nextPage >= movies.length) {
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ✅ الخلفية مع تأثير ضبابي (Blur)
        Positioned.fill(
          child: Image.network(
            _currentImageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: Colors.grey[800]);
            },
          ),
        ),
        // ✅ طبقة ضبابية (Blur) بنسبة 40%
        Positioned.fill(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(
              sigmaX: 8.0,   // ✅ مستوى الضبابية الأفقي (40%)
              sigmaY: 8.0,   // ✅ مستوى الضبابية الرأسي (40%)
            ),
            child: Container(
              color: Colors.black.withOpacity(0.3), // ✅ طبقة داكنة خفيفة
            ),
          ),
        ),
        // ✅ المحتوى الرئيسي
        SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: const Text(
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
                      itemCount: movies.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                          _currentImageUrl = 'https://picsum.photos/id/${movies[index]['imageId']}/400/500';
                        });
                        _resetAutoScroll();
                      },
                      itemBuilder: (context, index) {
                        final isCenter = index == _currentPage;
                        return AnimatedContainer(
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
                          child: _buildMovieCard(movies[index], isCenter),
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
                      itemCount: validImageIds.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(
                                'https://picsum.photos/id/${validImageIds[index]}/120/150',
                              ),
                              fit: BoxFit.cover,
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
                      itemCount: validImageIds.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(
                                'https://picsum.photos/id/${validImageIds[index]}/120/150',
                              ),
                              fit: BoxFit.cover,
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

  Widget _buildMovieCard(Map<String, dynamic> movie, bool isCenter) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://picsum.photos/id/${movie['imageId']}/400/500',
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
                    movie['rating'],
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
                    movie['title'],
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
                    movie['subtitle'],
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