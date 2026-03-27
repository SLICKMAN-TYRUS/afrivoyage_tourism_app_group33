import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:afrivoyage/data/repositories/auth_repository.dart';
import 'package:afrivoyage/presentation/tourist/blocs/auth_bloc.dart';
import 'package:afrivoyage/presentation/tourist/screens/login_screen.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('renders login form with email and password fields',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => AuthBloc(authRepository: AuthRepository()),
            child: const LoginScreen(),
          ),
        ),
      );

      expect(find.text('AfriVoyage'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('toggles between login and signup', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => AuthBloc(authRepository: AuthRepository()),
            child: const LoginScreen(),
          ),
        ),
      );

      // Initially shows Login
      expect(find.text('Login'), findsOneWidget);

      // Tap Sign Up toggle
      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      expect(find.text('Create Account'), findsOneWidget);
    });
  });
}
