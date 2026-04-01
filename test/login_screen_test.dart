void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });

  group('LoginScreen Widget Tests', () {
    testWidgets('renders login form with email and password fields',
        (tester) async {
      // LoginScreen manages its own BlocProvider internally
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pump();

      expect(find.text('AfriVoyage'), findsOneWidget);
      // Login form has TextFormFields (email address + password)
      expect(find.byType(TextFormField), findsAtLeast(2));
      expect(find.text('Email address'), findsAtLeast(1));
      expect(find.text('Password'), findsAtLeast(1));
      // 'Login' appears in the TabBar tab label
      expect(find.text('Login'), findsWidgets);
    });

    testWidgets('toggles between login and signup', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pump();

      // Initially on Login tab — tab bar shows both labels
      expect(find.text('Login'), findsWidgets);

      // Tap Sign Up toggle
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsOneWidget);
    });
  });
}
