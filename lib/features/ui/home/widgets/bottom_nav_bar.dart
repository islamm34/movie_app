// lib/features/ui/home/widgets/bottom_nav_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/utilities/aap_assets.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,  // ✅ شفاف تماماً
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFF6BD00).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, AppAssets.homeSvg, 'Home'),
          _buildNavItem(1, AppAssets.searchSvg, 'Search'),
          _buildNavItem(2, AppAssets.exploreSvg, 'Explore'),
          _buildNavItem(3, AppAssets.profileSvg, 'Profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String iconPath, String label) {
    final isSelected = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(
                isSelected ? const Color(0xFFF6BD00) : Colors.white70,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isSelected ? const Color(0xFFF6BD00) : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}