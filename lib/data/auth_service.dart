import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper over FirebaseAuth for the sign-in methods we support on web:
/// Google popup and phone OTP (with reCAPTCHA).
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> authState() => _auth.authStateChanges();

  Future<UserCredential> signInWithGoogle() {
    final provider = GoogleAuthProvider()
      ..addScope('email')
      ..setCustomParameters({'prompt': 'select_account'});
    return _auth.signInWithPopup(provider);
  }

  /// Starts phone verification on web. Returns a [ConfirmationResult] whose
  /// `confirm(code)` completes the sign-in.
  Future<ConfirmationResult> startPhoneSignIn(String e164Phone) {
    return _auth.signInWithPhoneNumber(e164Phone);
  }

  Future<void> signOut() => _auth.signOut();
}
