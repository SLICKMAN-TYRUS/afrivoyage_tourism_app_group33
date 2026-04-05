import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  // Optional overrides — kept as nullable fields so the constructor
  // never touches Firebase.instance at all.
  final FirebaseAuth? _authOverride;
  final GoogleSignIn? _googleSignInOverride;
  final FirebaseFirestore? _firestoreOverride;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  })  : _authOverride = firebaseAuth,
        _googleSignInOverride = googleSignIn,
        _firestoreOverride = firestore;

  // ── Lazy getters ──
  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;
  GoogleSignIn get _googleSignIn => _googleSignInOverride ?? GoogleSignIn();
  FirebaseFirestore get _db => _firestoreOverride ?? FirebaseFirestore.instance;

  // ── Public accessors ──
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Validation Methods (ADDED FOR LOGIN_SCREEN) ──
  bool validateEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.trim());
  }

  bool validatePassword(String password) {
    return password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]'));
  }

  bool validatePhone(String phone) {
    return RegExp(r'^\+?[0-9]{9,15}$').hasMatch(phone.replaceAll(' ', ''));
  }

  // ── Sign in ──
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

      if (user != null && result.additionalUserInfo?.isNewUser == true) {
        await _saveProfile(
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

  // ── Sign up ──
  Future<User?> signUpWithProfile({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String dateOfBirth,
    required String accountType,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = result.user;
      if (user == null) throw Exception('Account creation failed.');

      await user.updateDisplayName(fullName.trim());

      await _saveProfile(
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
      if (e is Exception) rethrow;
      throw Exception('Sign up failed. Please try again.');
    }
  }

  Future<void> _saveProfile({
    required String uid,
    required String fullName,
    required String email,
    required String phone,
    required String dateOfBirth,
    required String accountType,
  }) async {
    await _db.collection('users').doc(uid).set({
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'accountType': accountType,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Profile fetch ──
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.data();
    } catch (_) {
      return null;
    }
  }

  // ── Sign out ──
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // ── Password reset ──
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthError(e));
    } catch (_) {
      throw Exception('Failed to send reset email. Please try again.');
    }
  }

  // ── Error mapping ──
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
