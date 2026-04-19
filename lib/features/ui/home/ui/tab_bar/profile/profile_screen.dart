import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_app/core/utilities/aap_assets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:avatar_maker/avatar_maker.dart';
import '../../../../../../core/utilities/app_routs.dart';
import '../../../../movie_details/ui/movie_details_screen.dart';

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

  late AvatarMakerController _avatarMakerController;
  Uint8List? _savedAvatarBytes;
  final GlobalKey _avatarKey = GlobalKey();

  // متغير لتحديث الـ UI بعد الحفظ
  int _avatarVersion = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadUserMovies();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _currentUser = user;
    });
    await _loadSavedAvatar();
  }

  // تحميل الـ Avatar المحفوظ
  Future<void> _loadSavedAvatar() async {
    setState(() {
      _isAvatarLoading = true;
    });

    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    final prefs = await SharedPreferences.getInstance();
    final avatarKey = 'avatar_bytes_$userId';

    // إنشاء Controller جديد
    _avatarMakerController = NonPersistentAvatarMakerController(
      customizedPropertyCategories: [],
    );

    // تحميل الصورة المحفوظة
    final String? avatarBytesString = prefs.getString(avatarKey);

    if (avatarBytesString != null && avatarBytesString.isNotEmpty) {
      try {
        final bytes = base64Decode(avatarBytesString);
        setState(() {
          _savedAvatarBytes = bytes;
        });
        print('Avatar loaded successfully! Size: ${bytes.length} bytes');
      } catch (e) {
        print('Error loading avatar: $e');
        _savedAvatarBytes = null;
      }
    } else {
      _savedAvatarBytes = null;
    }

    setState(() {
      _isAvatarLoading = false;
    });
  }

  // تصوير الـ Avatar وحفظه
  Future<void> _captureAndSaveAvatar() async {
    try {
      print('Capturing avatar...');

      final RenderRepaintBoundary? boundary = _avatarKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        print('Boundary is null');
        return;
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final bytes = byteData.buffer.asUint8List();
        final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
        final prefs = await SharedPreferences.getInstance();
        final avatarKey = 'avatar_bytes_$userId';

        // تحويل bytes إلى Base64 string وحفظه
        final avatarString = base64Encode(bytes);
        await prefs.setString(avatarKey, avatarString);

        setState(() {
          _savedAvatarBytes = bytes;
          _avatarVersion++;
        });

        print('Avatar saved successfully! Size: ${bytes.length} bytes');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Avatar saved successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else {
        print('Failed to capture avatar - byteData is null');
      }
    } catch (e) {
      print('Error capturing avatar: $e');
    }
  }

  Future<void> _loadUserMovies() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    final prefs = await SharedPreferences.getInstance();

    final watchlistJson = prefs.getStringList('watchlist_$userId') ?? [];
    final historyJson = prefs.getStringList('history_$userId') ?? [];

    setState(() {
      _watchlistMovies = _parseMovies(watchlistJson);
      _historyMovies = _parseMovies(historyJson);
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

  void _openAvatarCustomizer() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AvatarCustomizerPage(
          controller: _avatarMakerController,
        ),
      ),
    );

    if (result == true && mounted) {
      // ننتظر شوية عشان الـ Avatar يترسم
      await Future.delayed(const Duration(milliseconds: 300));
      await _captureAndSaveAvatar();
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

    // لو فيه صورة محفوظة، نعرضها
    if (_savedAvatarBytes != null) {
      return CircleAvatar(
        radius: 45,
        backgroundColor: const Color(0xFF282A28),
        child: ClipOval(
          child: Image.memory(
            _savedAvatarBytes!,
            width: 90,
            height: 90,
            fit: BoxFit.cover,
            key: ValueKey(_avatarVersion),
            errorBuilder: (context, error, stackTrace) {
              print('Error displaying saved avatar: $error');
              return RepaintBoundary(
                key: _avatarKey,
                child: AvatarMakerAvatar(
                  radius: 45,
                  backgroundColor: const Color(0xFF282A28),
                  controller: _avatarMakerController,
                ),
              );
            },
          ),
        ),
      );
    }

    // لو مفيش صورة محفوظة، نعرض الـ Avatar العادي
    return RepaintBoundary(
      key: _avatarKey,
      child: AvatarMakerAvatar(
        radius: 45,
        backgroundColor: const Color(0xFF282A28),
        controller: _avatarMakerController,
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
                                  onTap: _openAvatarCustomizer,
                                  child: _buildAvatar(),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _currentUser?.displayName ??
                                      (_currentUser?.email?.split('@').first ?? 'John Safwat'),
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
                            _buildStatItem(_watchlistMovies.length.toString(), 'Wish List'),
                            const SizedBox(width: 30),
                            _buildStatItem(_historyMovies.length.toString(), 'History'),
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
                          Tab(icon: Icon(Icons.list, color: Color(0xFFF6BD00)), text: 'Watch List'),
                          Tab(icon: Icon(Icons.folder, color: Color(0xFFF6BD00)), text: 'History'),
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
              onPressed: _openAvatarCustomizer,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF6BD00),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Edit Profile',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
Image.asset(AppAssets.Empty1, width: 200, height: 200),
             SizedBox(height: 10),
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
        return GestureDetector(
          onTap: () => _navigateToMovieDetails(movie['id']),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Image.network(
                  movie['imageUrl'],
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
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Color(0xFFF6BD00), size: 10),
                        const SizedBox(width: 2),
                        Text(
                          movie['rating'],
                          style: const TextStyle(color: Colors.white, fontSize: 10),
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

// ==================== Avatar Customizer Page ====================
class AvatarCustomizerPage extends StatefulWidget {
  final AvatarMakerController controller;

  const AvatarCustomizerPage({
    super.key,
    required this.controller,
  });

  @override
  State<AvatarCustomizerPage> createState() => _AvatarCustomizerPageState();
}

class _AvatarCustomizerPageState extends State<AvatarCustomizerPage> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF121312),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: const Text(
          'Customize Avatar',
          style: TextStyle(color: Color(0xFFF6BD00), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Save',
              style: TextStyle(color: Color(0xFFF6BD00), fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: AvatarMakerAvatar(
                radius: 100,
                backgroundColor: const Color(0xFF282A28),
                controller: widget.controller,
              ),
            ),
            const SizedBox(height: 30),
            AvatarMakerCustomizer(
              scaffoldWidth: min(600, width * 0.9),
              controller: widget.controller,
              theme: AvatarMakerThemeData(
                boxDecoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}