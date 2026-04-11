import 'package:flutter/material.dart';
import 'package:movie_app/features/ui/splash/splash_screen.dart';

import '../../features/ui/auth/login_screen.dart';

class AppRoutes {
  static const String home = '/home'; // تغيير من / إلى /home
  static const String splash = '/';    // جعل السبلش هي المسار الرئيسي الابتدائي

  static Map<String, WidgetBuilder> get routes => {
    home: (context) => const LoginScreen(),
    splash: (context) => const SplashScreen(),
  };
}
