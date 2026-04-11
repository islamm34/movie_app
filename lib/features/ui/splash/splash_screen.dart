import 'package:flutter/material.dart';
import '../../../core/utilities/app_routs.dart';
import 'onboarding_data_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // دالة للحصول على الصورة حسب الصفحة الحالية من الـ Model
  String _getBackgroundImage(int index) {
    return OnboardingModel.datalist[index].image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121312),
      body: Stack(
        children: [
          // 1. الخلفية (الصور مالية الشاشة)
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: OnboardingModel.datalist.length,
            itemBuilder: (context, index) {
              return Image.asset(
                _getBackgroundImage(index),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              );
            },
          ),

          // 2. تدريج أسود (Gradient) لضمان وضوح النص الأبيض فوق أي صورة
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.5),
                  Colors.black.withOpacity(0.9),
                ],
                stops: const [0.4, 0.7, 1.0],
              ),
            ),
          ),

          // 3. المحتوى العائم (Floating Content) - نصوص وأزرار مباشرة على الصورة
          Positioned(
            bottom: 50, // مسافة من الأسفل
            left: 24,
            right: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // العنوان
                Text(
                  OnboardingModel.datalist[_currentPage].title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // الوصف (لو موجود وغير فارغ)
                if (OnboardingModel.datalist[_currentPage].description != null &&
                    OnboardingModel.datalist[_currentPage].description!.isNotEmpty)
                  Text(
                    OnboardingModel.datalist[_currentPage].description!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                const SizedBox(height: 40),

                // الأزرار
                _buildButtons(),
              ],
            ),
          ),

          // كلمة OnBoarding في الأعلى
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Text(
              "OnBoarding",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // دالة بناء الأزرار مع الشروط المطلوبة
  Widget _buildButtons() {
    final bool isLastPage = _currentPage == OnboardingModel.datalist.length - 1;
    // زر الباك يظهر فقط من الصفحة الثالثة (index 2)
    final bool showBack = _currentPage >= 2;

    return Column(
      children: [
        // زر الـ Next أو Finish
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              if (isLastPage) {
                // الانتقال للصفحة الرئيسية عند الضغط على Finish

                Navigator.pushReplacementNamed(context, AppRoutes.home);
              } else {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF6BD00), // اللون الأصفر
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 0,
            ),
            child: Text(
              OnboardingModel.datalist[_currentPage].buttonText,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),

        // زر الـ Back (يظهر فقط من index 2)
        if (showBack) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: OutlinedButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFF6BD00), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text(
                "Back",
                style: TextStyle(
                  color: Color(0xFFF6BD00),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}