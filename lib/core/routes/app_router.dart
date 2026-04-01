import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';
import 'error_page.dart';
import '../observers/router_observer.dart';

import '../../presentation/tourist/screens/login_screen.dart';
import '../../presentation/tourist/screens/home_screen.dart';
import '../../presentation/tourist/screens/settings_screen.dart';
import '../../presentation/tourist/screens/booking_screen.dart';
import '../../presentation/tourist/screens/impact_screen.dart';

import '../../presentation/provider/screens/provider_dashboard.dart';
import '../../presentation/provider/screens/provider_earnings.dart';
import '../../presentation/provider/screens/provider_listings.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

Stream<User?> get _authStream => FirebaseAuth.instance.authStateChanges();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RouteNames.login,
  debugLogDiagnostics: true,
  observers: [RouterObserver()],

  // ── Auth guard ─────────────────────────────────────────────
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final onAuth = state.matchedLocation == RouteNames.login;

    if (user == null && !onAuth) return RouteNames.login;
    if (user != null && onAuth) return RouteNames.home;
    return null;
  },

  // Re-evaluates redirect whenever Firebase auth state changes
  refreshListenable: _GoRouterRefreshStream(_authStream),

  errorBuilder: (context, state) => ErrorPage(error: state.error),

  routes: [
    // ── Login ───────────────────────────────────────────────
    GoRoute(
      path: RouteNames.login,
      name: RouteNames.loginName,
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => _slideTransitionPage(
        key: state.pageKey,
        child: const LoginScreen(),
        direction: AxisDirection.right,
      ),
    ),

    // ── Settings ────────────────────────────────────────────
    GoRoute(
      path: RouteNames.settings,
      name: RouteNames.settingsName,
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => _slideTransitionPage(
        key: state.pageKey,
        child: const SettingsScreen(),
        direction: AxisDirection.left,
      ),
    ),

    // ── Booking detail (full-screen, above shell) ───────────
    GoRoute(
      path: '/booking/:id',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => _slideTransitionPage(
        key: state.pageKey,
        child: BookingScreen(experienceId: state.pathParameters['id']),
        direction: AxisDirection.left,
      ),
    ),

    // ── Shell (bottom-nav tabs) ─────────────────────────────
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => child,
      routes: [
        GoRoute(
          path: RouteNames.home,
          name: RouteNames.homeName,
          pageBuilder: (context, state) => _noTransitionPage(
            key: state.pageKey,
            child: const HomeScreen(),
          ),
        ),
        GoRoute(
          path: RouteNames.bookings,
          name: RouteNames.bookingsName,
          pageBuilder: (context, state) => _noTransitionPage(
            key: state.pageKey,
            child: const BookingScreen(),
          ),
        ),
        GoRoute(
          path: RouteNames.impact,
          name: RouteNames.impactName,
          pageBuilder: (context, state) => _noTransitionPage(
            key: state.pageKey,
            child: const ImpactScreen(),
          ),
        ),
        GoRoute(
          path: RouteNames.provider,
          name: RouteNames.providerName,
          pageBuilder: (context, state) => _noTransitionPage(
            key: state.pageKey,
            child: const ProviderDashboard(),
          ),
          routes: [
            GoRoute(
              path: RouteNames.earningsSegment,
              name: RouteNames.earningsName,
              parentNavigatorKey: _rootNavigatorKey,
              pageBuilder: (context, state) => _slideTransitionPage(
                key: state.pageKey,
                child: const ProviderEarnings(),
                direction: AxisDirection.left,
              ),
            ),
            GoRoute(
              path: RouteNames.listingsSegment,
              name: RouteNames.listingsName,
              parentNavigatorKey: _rootNavigatorKey,
              pageBuilder: (context, state) => _slideTransitionPage(
                key: state.pageKey,
                child: const ProviderListings(),
                direction: AxisDirection.left,
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);

// ── Page transition helpers ────────────────────────────────────

Page<void> _noTransitionPage({required LocalKey key, required Widget child}) =>
    NoTransitionPage<void>(key: key, child: child);

Page<void> _slideTransitionPage({
  required LocalKey key,
  required Widget child,
  required AxisDirection direction,
}) {
  final startOffset = switch (direction) {
    AxisDirection.left => const Offset(1.0, 0.0),
    AxisDirection.right => const Offset(-1.0, 0.0),
    AxisDirection.up => const Offset(0.0, 1.0),
    AxisDirection.down => const Offset(0.0, -1.0),
  };
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        SlideTransition(
      position: Tween<Offset>(begin: startOffset, end: Offset.zero).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      ),
      child: child,
    ),
  );
}

// ── Bridges Firebase auth stream → GoRouter ChangeNotifier ────

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final dynamic _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
