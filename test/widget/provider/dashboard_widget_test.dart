import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:afrivoyage/presentation/provider/screens/provider_dashboard.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });

  group('ProviderDashboard Widget Tests', () {
    testWidgets('renders dashboard with earnings and bookings', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProviderDashboard(),
        ),
      );

      expect(find.text('Provider Dashboard'), findsOneWidget);
      expect(find.text('Welcome back,'), findsOneWidget);
      expect(find.text('This Month'), findsOneWidget);
      expect(find.text('Recent Bookings'), findsOneWidget);
      expect(find.text('Quick Actions'), findsOneWidget);
    });

    testWidgets('displays navigation buttons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProviderDashboard(),
        ),
      );

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Listings'), findsOneWidget);
      expect(find.text('Earnings'), findsOneWidget);
    });
  });
}
