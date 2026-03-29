import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:afrivoyage/data/repositories/auth_repository.dart';
import 'package:afrivoyage/presentation/tourist/blocs/auth_bloc.dart';
import 'package:afrivoyage/presentation/tourist/screens/login_screen.dart';

// ── Fake repository — no Firebase calls, safe to construct ───────────────

class _FakeAuthRepository extends AuthRepository {
  // super() is safe: lazy getters mean Firebase.instance is never evaluated
  _FakeAuthRepository() : super();

  @override
  User? get currentUser => null;

  @override
  Stream<User?> get authStateChanges => const Stream.empty();

  @override
  Future<User?> signInWithEmail(String email, String password) async => null;

  @override
  Future<User?> signInWithGoogle() async => null;

  @override
  Future<User?> signUpWithProfile({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String dateOfBirth,
    required String accountType,
  }) async =>
      null;

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<Map<String, dynamic>?> getUserProfile(String uid) async => null;
}

// ── Tests ─────────────────────────────────────────────────────────────────

void main() {
  group('LoginScreen Widget Tests', () {
    Widget buildSubject() => MaterialApp(
          home: BlocProvider(
            create: (_) =>
                AuthBloc(authRepository: _FakeAuthRepository()),
            child: const LoginScreen(),
          ),
        );

    testWidgets('renders AfriVoyage branding, tab bar, and login fields',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      // App title is visible
      expect(find.text('AfriVoyage'), findsOneWidget);

      // Tab bar with Login / Sign Up tabs
      expect(find.byType(TabBar), findsOneWidget);
      expect(find.text('Login'), findsWidgets);

      // Login form has exactly 2 TextFormFields (email + password)
      expect(find.byType(TextFormField), findsAtLeast(2));
    });

    testWidgets('tapping Sign Up tab shows account creation form',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      // Tap the Sign Up tab
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Sign up form renders its submit button and account-type section
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('I am a'), findsOneWidget);
    });
  });
}
