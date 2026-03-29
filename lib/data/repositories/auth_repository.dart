import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Sign in ───────────────────────────────────────────────

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthError(e));
    } catch (_) {
      throw Exception('Login failed. Please try again.');
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      final user = result.user;

      // Save profile if first-time Google sign-in
      if (user != null && result.additionalUserInfo?.isNewUser == true) {
        await _saveUserProfile(
          uid: user.uid,
          fullName: user.displayName ?? '',
          email: user.email ?? '',
          phone: user.phoneNumber ?? '',
          dateOfBirth: '',
          accountType: 'tourist',
        );
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthError(e));
    } catch (_) {
      throw Exception('Google Sign-In failed. Please try again.');
    }
  }

  // ── Sign up ───────────────────────────────────────────────

  Future<User?> signUpWithProfile({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String dateOfBirth,
    required String accountType, // 'tourist' | 'provider'
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = result.user;
      if (user == null) throw Exception('Account creation failed.');

      // Set display name so it shows throughout the app
      await user.updateDisplayName(fullName.trim());

      // Persist full profile to Firestore
      await _saveUserProfile(
        uid: user.uid,
        fullName: fullName.trim(),
        email: email.trim(),
        phone: phone.trim(),
        dateOfBirth: dateOfBirth,
        accountType: accountType,
      );

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthError(e));
    } catch (e) {
      // Re-throw if it's already a clean Exception from above
      if (e is Exception) rethrow;
      throw Exception('Sign up failed. Please try again.');
    }
  }

  Future<void> _saveUserProfile({
    required String uid,
    required String fullName,
    required String email,
    required String phone,
    required String dateOfBirth,
    required String accountType,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'accountType': accountType,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Fetch profile ─────────────────────────────────────────

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (_) {
      return null;
    }
  }

  // ── Sign out ──────────────────────────────────────────────

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // ── Password reset ────────────────────────────────────────

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthError(e));
    } catch (_) {
      throw Exception('Failed to send reset email. Please try again.');
    }
  }

  // ── Helpers ───────────────────────────────────────────────

  String _friendlyAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password. Please try again.';
      case 'email-already-in-use':
        return 'An account with this email already exists. Try logging in.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters with letters and numbers.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Contact support.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}

// ── Standalone validators ─────────────────────────────────────

bool validateEmail(String email) {
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.trim());
}

bool validatePassword(String password) {
  if (password.length < 8) return false;
  if (!password.contains(RegExp(r'[A-Z]'))) return false;
  if (!password.contains(RegExp(r'[a-z]'))) return false;
  if (!password.contains(RegExp(r'[0-9]'))) return false;
  return true;
}

bool validatePhone(String phone) {
  return RegExp(r'^\+?[0-9]{9,15}$').hasMatch(phone.replaceAll(' ', ''));
}
