// lib/features/ui/auth/register_screen.dart

import 'package:flutter/material.dart';
import 'package:movie_app/core/utilities/aap_assets.dart';
import '../../widgets/custom_text_field.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121312),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Register',
          style: TextStyle(
            color: Color(0xFFF6BD00),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      child: Image.asset(AppAssets.splashIconPng),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              const NameTextField(),
              const SizedBox(height: 20),
              const EmailTextField(),
              const SizedBox(height: 20),
              const PasswordTextField(hintText: 'Password'),
              const SizedBox(height: 20),
              const PasswordTextField(hintText: 'Confirm Password'),
              const SizedBox(height: 20),
              const PhoneTextField(),
              const SizedBox(height: 40),
              CustomButton(text: 'Create Account', onPressed: () {}),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already Have Account ? ',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Color(0xFFF6BD00),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
