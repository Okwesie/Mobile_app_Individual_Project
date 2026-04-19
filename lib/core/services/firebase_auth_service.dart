import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  FirebaseAuthService._();
  static final FirebaseAuthService instance = FirebaseAuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await cred.user?.updateDisplayName(name.trim());
    await cred.user?.reload();
    return cred;
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) =>
      _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

  Future<UserCredential?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // user cancelled

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// Converts a FirebaseAuthException code to a human-readable message.
  static String humaniseError(FirebaseAuthException e) {
    return switch (e.code) {
      'email-already-in-use' => 'An account already exists with this email.',
      'invalid-email' => 'Please enter a valid email address.',
      'weak-password' => 'Password must be at least 6 characters.',
      'user-not-found' => 'No account found with this email.',
      'wrong-password' => 'Incorrect password. Please try again.',
      'invalid-credential' => 'Incorrect email or password.',
      'user-disabled' => 'This account has been disabled.',
      'too-many-requests' =>
        'Too many attempts. Please try again later.',
      'network-request-failed' =>
        'Network error. Check your connection.',
      _ => e.message ?? 'An error occurred. Please try again.',
    };
  }
}
