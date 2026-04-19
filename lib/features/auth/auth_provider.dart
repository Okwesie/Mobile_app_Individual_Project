import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:adventure_logger/core/services/firebase_auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final FirebaseAuthService _svc = FirebaseAuthService.instance;

  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  String? _error;
  bool _loading = false;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get error => _error;
  bool get loading => _loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    _svc.authStateChanges.listen((user) {
      _user = user;
      _status = user != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
      notifyListeners();
    });
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) => _run(() => _svc.signUpWithEmail(
        name: name,
        email: email,
        password: password,
      ));

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) => _run(() => _svc.signInWithEmail(email: email, password: password));

  Future<bool> signInWithGoogle() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final cred = await _svc.signInWithGoogle();
      _loading = false;
      notifyListeners();
      return cred != null;
    } on FirebaseAuthException catch (e) {
      _error = FirebaseAuthService.humaniseError(e);
      _loading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Google sign-in failed. Please try again.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _svc.sendPasswordReset(email);
      _loading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = FirebaseAuthService.humaniseError(e);
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _svc.signOut();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> _run(Future<UserCredential> Function() fn) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await fn();
      _loading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = FirebaseAuthService.humaniseError(e);
      _loading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }
}
