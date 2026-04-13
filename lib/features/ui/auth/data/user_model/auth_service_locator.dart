// lib/data/auth/di/auth_service_locator.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/auth_repository.dart';
import '../data_source/auth_data_source.dart';
import '../repository/auth_repository_impl.dart';

class AuthServiceLocator {
  static final AuthServiceLocator _instance = AuthServiceLocator._internal();
  factory AuthServiceLocator() => _instance;
  AuthServiceLocator._internal();

  late final FirebaseAuth _firebaseAuth;
  late final GoogleSignIn _googleSignIn;
  late final AuthDataSource _authDataSource;
  late final AuthRepository _authRepository;

  void init() {
    _firebaseAuth = FirebaseAuth.instance;
    _googleSignIn = GoogleSignIn(scopes: ['email']);
    _authDataSource = FirebaseAuthDataSource(
      firebaseAuth: _firebaseAuth,
      googleSignIn: _googleSignIn,
    );
    _authRepository = AuthRepositoryImpl(
      firebaseAuth: _firebaseAuth,
      googleSignIn: _googleSignIn,
    ) as AuthRepository;
  }

  AuthRepository get authRepository => _authRepository;
  AuthDataSource get authDataSource => _authDataSource;
  FirebaseAuth get firebaseAuth => _firebaseAuth;
  GoogleSignIn get googleSignIn => _googleSignIn;
}