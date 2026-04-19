import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../core/utilities/aap_assets.dart';
import '../../../../../../core/utilities/app_routs.dart';
import '../../../../movie_details/ui/movie_details_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;
  List<Map<String, dynamic>> _watchlistMovies = [];
  List<Map<String, dynamic>> _historyMovies = [];
  bool _isLoading = true;
  bool _isAvatarLoading = true;

  String? _savedAvatarBase64;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream subscriptions
  Stream<QuerySnapshot>? _watchlistStream;
  Stream<QuerySnapshot>? _historyStream;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _setupFirestoreStreams();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _currentUser = user;
    });
    await _loadSavedAvatar();
  }

  Future<void> _loadSavedAvatar() async {
    setState(() {
      _isAvatarLoading = true;
    });

    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';

    // محاولة تحميل من Firestore أولاً
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      try {
        final doc = await _firestore.collection('users').doc(userId).get();
        if (doc.exists) {
          final data = doc.data();
          if (data != null && data['avatar'] != null && data['avatar'].toString().isNotEmpty) {
            setState(() {
              _savedAvatarBase64 = data['avatar'] as String?;
            });
            print('✅ Avatar loaded from Firestore');
            setState(() {
              _isAvatarLoading = false;
            });
            return;
          }
        }
      } catch (e) {
        print('Error loading avatar from Firestore: $e');
      }
    }

    // تحميل من SharedPreferences كنسخة احتياطية
    final prefs = await SharedPreferences.getInstance();
    final avatarKey = 'avatar_$userId';
    _savedAvatarBase64 = prefs.getString(avatarKey);

    setState(() {
      _isAvatarLoading = false;
    });
  }

  void _setupFirestoreStreams() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    // إعداد الـ Stream للـ Watchlist
    _watchlistStream = _firestore
        .collection('users')
        .doc(userId)
        .collection('watchlist')
        .orderBy('addedAt', descending: true)
        .snapshots();

    // إعداد الـ Stream للـ History
    _historyStream = _firestore
        .collection('users')
        .doc(userId)
        .collection('history')
        .orderBy('watchedAt', descending: true)
        .limit(20)
        .snapshots();
  }

  // تحميل الـ Watchlist من Firestore مع Stream
  Future<void> _loadWatchlistFromFirestore() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    _watchlistStream?.listen((snapshot) {
      final List<Map<String, dynamic>> movies = [];
      for (var doc in snapshot.docs) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        movies.add({
          'id': data['id'] ?? 0,
          'title': data['title'] ?? '',
          'rating': data['rating'] ?? '',
          'imageUrl': data['imageUrl'] ?? '',
          'year': data['year'] ?? '',
          'addedAt': data['addedAt'],
        });
      }

      if (mounted) {
        setState(() {
          _watchlistMovies = movies;
        });
      }
      print('✅ Watchlist updated: ${movies.length} movies');
    }, onError: (error) {
      print('❌ Error loading watchlist: $error');
    });
  }

  // تحميل الـ History من Firestore مع Stream
  Future<void> _loadHistoryFromFirestore() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    _historyStream?.listen((snapshot) {
      final List<Map<String, dynamic>> movies = [];
      for (var doc in snapshot.docs) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        movies.add({
          'id': data['id'] ?? 0,
          'title': data['title'] ?? '',
          'rating': data['rating'] ?? '',
          'imageUrl': data['imageUrl'] ?? '',
          'year': data['year'] ?? '',
          'watchedAt': data['watchedAt'],
        });
      }

      if (mounted) {
        setState(() {
          _historyMovies = movies;
        });
      }
      print('✅ History updated: ${movies.length} movies');
    }, onError: (error) {
      print('❌ Error loading history: $error');
    });
  }

  Future<void> _loadUserMovies() async {
    setState(() {
      _isLoading = true;
    });

    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      // تحميل الـ Watchlist و History من Firestore مع Stream
      await _loadWatchlistFromFirestore();
      await _loadHistoryFromFirestore();
    } else {
      // للمستخدمين الضيوف، تحميل من SharedPreferences
      final guestId = 'guest';
      final prefs = await SharedPreferences.getInstance();
      final watchlistJson = prefs.getStringList('watchlist_$guestId') ?? [];
      final historyJson = prefs.getStringList('history_$guestId') ?? [];

      setState(() {
        _watchlistMovies = _parseMovies(watchlistJson);
        _historyMovies = _parseMovies(historyJson);
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> _parseMovies(List<String> jsonList) {
    return jsonList.map((json) {
      final parts = json.split('|||');
      return {
        'id': int.parse(parts[0]),
        'title': parts[1],
        'rating': parts[2],
        'imageUrl': parts[3],
        'year': parts[4],
      };
    }).toList();
  }

  void _openEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfileScreen(),
      ),
    );

    if (result == true && mounted) {
      await _loadSavedAvatar();
      await _loadUserData();
      setState(() {});
    }
  }

  Widget _buildAvatar() {
    if (_isAvatarLoading) {
      return Container(
        width: 90,
        height: 90,
        decoration: const BoxDecoration(
          color: Color(0xFF282A28),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              color: Color(0xFFF6BD00),
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    if (_savedAvatarBase64 != null && _savedAvatarBase64!.isNotEmpty) {
      return Container(
        width: 90,
        height: 90,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF282A28),
        ),
        child: ClipOval(
          child: Image.memory(
            base64Decode(_savedAvatarBase64!),
            width: 90,
            height: 90,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Error loading avatar image: $error');
              return const Icon(
                Icons.person,
                size: 50,
                color: Colors.white54,
              );
            },
          ),
        ),
      );
    }

    return Container(
      width: 90,
      height: 90,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF282A28),
      ),
      child: const Icon(
        Icons.person,
        size: 50,
        color: Colors.white54,
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

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    // إذا كان المستخدم مسجل، نبدأ تحميل البيانات
    if (FirebaseAuth.instance.currentUser?.uid != null && _isLoading) {
      _loadUserMovies();
    } else if (FirebaseAuth.instance.currentUser?.uid == null && _isLoading) {
      _loadUserMovies();
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF121312),
        body: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: _openEditProfile,
                                  child: _buildAvatar(),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _currentUser?.displayName ??
                                      (_currentUser?.email?.split('@').first ??
                                          'John Safwat'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_currentUser?.email != null)
                                  Text(
                                    _currentUser!.email!,
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                            const Spacer(),
                            _buildStatItem(
                              _watchlistMovies.length.toString(),
                              'Wish List',
                            ),
                            const SizedBox(width: 30),
                            _buildStatItem(
                              _historyMovies.length.toString(),
                              'History',
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      _buildActionButtons(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    Container(
                      color: const Color(0xFF121312),
                      child: const TabBar(
                        indicatorColor: Color(0xFFF6BD00),
                        indicatorWeight: 3,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey,
                        tabs: [
                          Tab(
                            icon: Icon(Icons.list, color: Color(0xFFF6BD00)),
                            text: 'Watch List',
                          ),
                          Tab(
                            icon: Icon(Icons.folder, color: Color(0xFFF6BD00)),
                            text: 'History',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: [
                _buildMoviesGrid(_watchlistMovies, 'Watch List'),
                _buildMoviesGrid(_historyMovies, 'History'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _openEditProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF6BD00),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Edit Profile',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: Colors.white, size: 20),
              label: const Text(
                'Exit',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoviesGrid(List<Map<String, dynamic>> movies, String title) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFF6BD00)),
      );
    }

    if (movies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppAssets.Empty1),
            const SizedBox(height: 10),
            const Text(
              'No Movies Added',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.65,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        final movieId = movie['id'] as int? ?? 0;
        final movieTitle = movie['title'] as String? ?? '';
        final movieRating = movie['rating'] as String? ?? '';
        final movieImageUrl = movie['imageUrl'] as String? ?? '';

        return GestureDetector(
          onTap: () => _navigateToMovieDetails(movieId),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Image.network(
                  movieImageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[800],
                      child: const Icon(Icons.error, color: Colors.white54),
                    );
                  },
                ),
                Positioned(
                  top: 5,
                  left: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFF6BD00),
                          size: 10,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          movieRating,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this.child);
  final Widget child;

  @override
  double get minExtent => 70.0;

  @override
  double get maxExtent => 70.0;

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    return child;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}