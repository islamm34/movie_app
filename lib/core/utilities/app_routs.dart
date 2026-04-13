// lib/core/utilities/app_routs.dart

import 'package:flutter/material.dart';
import '../../features/ui/auth/ui/forget_password/forget_pasword_screen.dart';
import '../../features/ui/auth/ui/login_screen/login_screen.dart';
import '../../features/ui/auth/ui/register_screen/register_screen.dart';
import '../../features/ui/home/ui/home_screen.dart';
import '../../features/ui/splash/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgetPassword = '/forget_password';
  static const String home = '/home';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    forgetPassword: (context) => const ForgotPasswordScreen(),
    home: (context) => const HomeScreen(), // أضف هذا السطر
  };
}