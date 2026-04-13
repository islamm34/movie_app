import 'package:flutter/material.dart';
import 'package:movie_app/features/ui/splash/splash_screen.dart';

import '../../features/ui/auth/ui/forget_password/forget_pasword_screen.dart';
import '../../features/ui/auth/ui/login_screen/login_screen.dart';
import '../../features/ui/auth/ui/register_screen/register_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String Register = '/register';
  static const String ForgetPassword = '/forget_password';

  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginScreen(),
    splash: (context) => const SplashScreen(),
    Register: (context) => const RegisterScreen(),
    ForgetPassword: (context) => const ForgotPasswordScreen(),
  };
}
