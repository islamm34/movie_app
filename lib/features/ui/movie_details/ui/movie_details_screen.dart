// lib/features/ui/movie_details/movie_details_screen.dart

import 'package:flutter/material.dart';
import 'package:movie_app/features/ui/home/domain/movie_entity.dart';
import 'package:url_launcher/url_launcher.dart';

class MovieDetailsScreen extends StatelessWidget {
  final MovieEntity movie;

  const MovieDetailsScreen({
    super.key,
    required this.movie,
  });

  Future<void> _launchMovieUrl() async {
    if (movie.url != null && movie.url!.isNotEmpty) {
      final Uri url = Uri.parse(movie.url!);
      try {
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch $url';
        }
      } catch (e) {
        print('Error launching URL: $e');
      }
    }
  }

  Future<void> _launchTrailer() async {
    if (movie.ytTrailerCode != null && movie.ytTrailerCode!.isNotEmpty) {
      final String youtubeUrl = 'https://www.youtube.com/watch?v=${movie.ytTrailerCode}';
      final Uri url = Uri.parse(youtubeUrl);
      try {
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch $url';
        }
      } catch (e) {
        print('Error launching YouTube: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121312),
      body: Container(
        width: 430,           // ✅ العرض المحدد
        height: 2961,         // ✅ الارتفاع المحدد
        clipBehavior: Clip.antiAlias,  // ✅ clipToOutline
        decoration: const BoxDecoration(
          color: Color(0xFF121312),   // ✅ الخلفية
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero image
                Stack(
                  children: [
                    Container(
                      width: 430,
                      height: 500,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(movie.largeCoverImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      width: 430,
                      height: 500,
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
                    // Movie title overlay
                    Positioned(
                      bottom: 20,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.titleEnglish,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            movie.year.toString(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Back button
                    Positioned(
                      top: 16,
                      left: 16,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 10,
                          height: 20,
                          child:  Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Watch Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _launchMovieUrl,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF6BD00),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Watch',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            icon: Icons.favorite,
                            value: '15',
                            color: Colors.red,
                          ),
                          _buildStatItem(
                            icon: Icons.comment,
                            value: '90',
                            color: Colors.white70,
                          ),
                          _buildStatItem(
                            icon: Icons.star,
                            value: movie.formattedRating,
                            color: const Color(0xFFF6BD00),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Genres
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: movie.genres.map((genre) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white24,
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              genre,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      // Storyline
                      const Text(
                        'Storyline',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        movie.summary.isNotEmpty
                            ? movie.summary
                            : 'No summary available for this movie.',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Additional Info Box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              'Language',
                              movie.language.toUpperCase(),
                            ),
                            if (movie.imdbCode != null && movie.imdbCode!.isNotEmpty)
                              const Divider(color: Colors.white24),
                            if (movie.imdbCode != null && movie.imdbCode!.isNotEmpty)
                              _buildInfoRow(
                                'IMDB Code',
                                movie.imdbCode!,
                              ),
                            const Divider(color: Colors.white24),
                            _buildInfoRow(
                              'Date Uploaded',
                              movie.dateUploaded,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Watch Trailer Button
                      if (movie.ytTrailerCode != null &&
                          movie.ytTrailerCode!.isNotEmpty)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: _launchTrailer,
                            icon: const Icon(Icons.play_circle_outline),
                            label: const Text('Watch Trailer'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}