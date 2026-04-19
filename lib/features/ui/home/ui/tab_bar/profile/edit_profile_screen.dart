import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:avatar_maker/avatar_maker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../core/utilities/app_routs.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  User? _currentUser;
  bool _isLoading = false;
  String? _avatarBase64;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAvatar();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _currentUser = user;
    });

    if (user != null) {
      // تحميل البيانات من Firestore
      await _loadUserFromFirestore(user.uid);
      // تحميل رقم الهاتف من SharedPreferences كنسخة احتياطية
      await _loadPhoneNumber();
    }
  }

  Future<void> _loadUserFromFirestore(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          _nameController.text = data['name'] ?? '';
          _phoneController.text = data['phone'] ?? '';

          // تحديث displayName في Firebase Auth
          if (data['name'] != null && data['name'].isNotEmpty) {
            await _currentUser?.updateDisplayName(data['name']);
          }
        }
      }
    } catch (e) {
      print('Error loading from Firestore: $e');
    }
  }

  Future<void> _loadPhoneNumber() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('phone_$userId') ?? '';
    if (_phoneController.text.isEmpty) {
      setState(() {
        _phoneController.text = phone;
      });
    }
  }

  Future<void> _loadAvatar() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';

    // أولاً: محاولة تحميل الصورة من Firestore
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['avatar'] != null && data['avatar'].toString().isNotEmpty) {
          setState(() {
            _avatarBase64 = data['avatar'];
          });
          print('✅ Avatar loaded from Firestore');
          return;
        }
      }
    } catch (e) {
      print('Error loading avatar from Firestore: $e');
    }

    // ثانياً: محاولة تحميل الصورة من SharedPreferences (نسخة احتياطية)
    final prefs = await SharedPreferences.getInstance();
    final avatarKey = 'avatar_$userId';
    _avatarBase64 = prefs.getString(avatarKey);
    setState(() {});
  }

  Future<void> _saveToFirestore() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final userData = {
        'name': _nameController.text,
        'phone': _phoneController.text,
        'avatar': _avatarBase64 ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
        'email': _currentUser?.email ?? '',
      };

      await _firestore.collection('users').doc(userId).set(
        userData,
        SetOptions(merge: true),
      );

      print('✅ Data saved to Firestore');
    } catch (e) {
      print('Error saving to Firestore: $e');
      rethrow;
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      // 1. تحديث displayName في Firebase Auth
      if (user != null && _nameController.text.isNotEmpty) {
        await user.updateDisplayName(_nameController.text);
      }

      // 2. حفظ البيانات في Firestore
      await _saveToFirestore();

      // 3. حفظ نسخة احتياطية في SharedPreferences
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('phone_$userId', _phoneController.text);
      if (_avatarBase64 != null) {
        await prefs.setString('avatar_$userId', _avatarBase64!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email != null) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: user!.email!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password reset email sent! Check your inbox.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF282A28),
        title: const Text(
          'Delete Account',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final userId = user.uid;

          // 1. حذف بيانات المستخدم من Firestore
          await _firestore.collection('users').doc(userId).delete();

          // 2. حذف بيانات المستخدم من SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('watchlist_$userId');
          await prefs.remove('history_$userId');
          await prefs.remove('avatar_$userId');
          await prefs.remove('phone_$userId');

          // 3. حذف حساب Firebase Auth
          await user.delete();

          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
                  (route) => false,
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting account: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _openAvatarPicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AvatarPickerScreen(
          onAvatarSaved: (String base64Image) async {
            setState(() {
              _avatarBase64 = base64Image;
            });
            // حفظ الصورة في Firestore فوراً
            await _saveToFirestore();
          },
        ),
      ),
    );
    if (result == true && mounted) {
      await _loadAvatar();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121312),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                // ==================== Pick Avatar Section ====================
                GestureDetector(
                  onTap: _openAvatarPicker,
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF282A28),
                          border: Border.all(
                            color: const Color(0xFFF6BD00),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: _avatarBase64 != null
                              ? Image.memory(
                            base64Decode(_avatarBase64!),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                              : const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Pick Avatar',
                        style: TextStyle(
                          color: Color(0xFFF6BD00),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ==================== Name Field ====================
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF282A28),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: 'John Safwat',
                      hintStyle: TextStyle(color: Colors.white54, fontSize: 16),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ==================== Phone Field ====================
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF282A28),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    controller: _phoneController,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: '01200000000',
                      hintStyle: TextStyle(color: Colors.white54, fontSize: 16),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),

                // ==================== Reset Password Link ====================
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _resetPassword,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Reset Password',
                      style: TextStyle(
                        color: Color(0xFFF6BD00),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // ==================== Update Data Button ====================
                GestureDetector(
                  onTap: _isLoading ? null : _updateProfile,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6BD00),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                          : const Text(
                        'Update Data',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ==================== Delete Account Button ====================
                GestureDetector(
                  onTap: _deleteAccount,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.5)),
                    ),
                    child: const Center(
                      child: Text(
                        'Delete Account',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFF6BD00)),
              ),
            ),
        ],
      ),
    );
  }
}

// ==================== Avatar Picker Screen ====================
class AvatarPickerScreen extends StatefulWidget {
  final Function(String)? onAvatarSaved;

  const AvatarPickerScreen({super.key, this.onAvatarSaved});

  @override
  State<AvatarPickerScreen> createState() => _AvatarPickerScreenState();
}

class _AvatarPickerScreenState extends State<AvatarPickerScreen> {
  late AvatarMakerController _avatarMakerController;
  final GlobalKey _avatarKey = GlobalKey();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _avatarMakerController = NonPersistentAvatarMakerController(
      customizedPropertyCategories: [],
    );
  }

  Future<void> _saveAvatar() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final RenderRepaintBoundary? boundary = _avatarKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 2.0);
        final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

        if (byteData != null) {
          final bytes = byteData.buffer.asUint8List();
          final base64String = base64Encode(bytes);

          final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
          final prefs = await SharedPreferences.getInstance();
          final avatarKey = 'avatar_$userId';

          // حفظ في SharedPreferences
          await prefs.setString(avatarKey, base64String);

          // حفظ في Firestore عبر الـ callback
          if (widget.onAvatarSaved != null) {
            widget.onAvatarSaved!(base64String);
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Avatar saved successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pick Avatar',
          style: TextStyle(color: Color(0xFFF6BD00), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveAvatar,
            child: const Text(
              'Save',
              style: TextStyle(color: Color(0xFFF6BD00), fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                RepaintBoundary(
                  key: _avatarKey,
                  child: Center(
                    child: AvatarMakerAvatar(
                      radius: 100,
                      backgroundColor: const Color(0xFF282A28),
                      controller: _avatarMakerController,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                AvatarMakerCustomizer(
                  scaffoldWidth: min(600, width * 0.9),
                  controller: _avatarMakerController,
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
          if (_isSaving)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFF6BD00)),
              ),
            ),
        ],
      ),
    );
  }
}