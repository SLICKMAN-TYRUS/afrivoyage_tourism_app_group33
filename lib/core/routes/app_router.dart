import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';
import 'error_page.dart';
import '../observers/router_observer.dart';

// Tourist screens — these already exist in your teammates' code
import '../../presentation/tourist/screens/login_screen.dart';
import '../../presentation/tourist/screens/home_screen.dart';
import '../../presentation/tourist/screens/booking_screen.dart';
import '../../presentation/tourist/screens/impact_screen.dart';

// Provider screens — already exist too
import '../../presentation/provider/screens/provider_dashboard.dart';
import '../../presentation/provider/screens/provider_earnings.dart';
import '../../presentation/provider/screens/provider_listings.dart';

// Shell (bottom nav wrapper) — you'll create this if it doesn't exist yet
// import '../../presentation/shared/shell/main_shell_page.dart';

// ---------------------------------------------------------------------------
// Navigator keys
// ---------------------------------------------------------------------------

// Two keys because we have two navigation stacks:
// - rootNavigatorKey  → full-screen routes (auth, splash, detail pages)
// - shellNavigatorKey → the bottom-nav tabs (home, bookings, impact, profile)
//
// Without this split, pressing back from a detail page would exit the shell
// entirely instead of just popping the detail. Annoying bug to debug if you
// miss it early on.
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

// ---------------------------------------------------------------------------
// Auth stream
// ---------------------------------------------------------------------------

// GoRouter listens to this so it knows when to re-run redirect().
// Firebase's authStateChanges() is perfect for this — fires on login AND logout.
Stream<User?> get _authStream => FirebaseAuth.instance.authStateChanges();

// ---------------------------------------------------------------------------
// appRouter
// ---------------------------------------------------------------------------

// The single GoRouter instance the whole app uses.
// Route tree (matches your team's existing screens):
//
//   /splash
//   /login
//   /shell  ← ShellRoute (bottom nav lives here)
//     /home
//     /bookings
//     /impact
//     /provider
//       /earnings
//       /listings
//
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RouteNames.login,

  // Super useful during development — logs every navigation event.
  // Set to false before the final submission / demo recording.
  debugLogDiagnostics: true,

  observers: [RouterObserver()],

  // ---------------------------------------------------------------------------
  // Auth guard
  // ---------------------------------------------------------------------------
  // Runs on every navigation AND whenever Firebase auth state changes.
  // Returns a redirect path, or null to let the navigation go through.
  redirect: (BuildContext context, GoRouterState state) {
    final user = FirebaseAuth.instance.currentUser;

    final onAuthFlow = {
      RouteNames.login,
      RouteNames.splash,
    }.contains(state.matchedLocation);

    // Not logged in and trying to reach a protected screen → back to login
    if (user == null && !onAuthFlow) return RouteNames.login;

    // Already logged in but sitting on the login screen → skip straight to home
    if (user != null && onAuthFlow) return RouteNames.home;

    return null; // all good, carry on
  },

  // Re-evaluates redirect() whenever auth state changes (login / logout).
  // Without this, logging out won't redirect until the next tap.
  refreshListenable: GoRouterRefreshStream(_authStream),

  errorBuilder: (context, state) => ErrorPage(error: state.error),

  // ---------------------------------------------------------------------------
  // Routes
  // ---------------------------------------------------------------------------
  routes: [

    // Login — the first real screen, slides in from the right
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

    // Shell — wraps the main tabs with the bottom navigation bar.
    // Every tab route lives inside here so the nav bar persists across them.
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
  
      // For now it just renders the child directly so routing still works.
      builder: (context, state, child) => child,
      // builder: (context, state, child) => MainShellPage(child: child),
      routes: [

        // Home tab — no transition between tabs feels snappier
        GoRoute(
          path: RouteNames.home,
          name: RouteNames.homeName,
          pageBuilder: (context, state) =>
              _noTransitionPage(key: state.pageKey, child: const HomeScreen()),
        ),

        // Bookings tab — maps to booking_screen.dart
        GoRoute(
          path: RouteNames.bookings,
          name: RouteNames.bookingsName,
          pageBuilder: (context, state) => _noTransitionPage(
            key: state.pageKey,
            child: const BookingScreen(),
          ),
        ),

        // Impact tab — maps to impact_screen.dart
        GoRoute(
          path: RouteNames.impact,
          name: RouteNames.impactName,
          pageBuilder: (context, state) => _noTransitionPage(
            key: state.pageKey,
            child: const ImpactScreen(),
          ),
        ),

        // Provider dashboard tab — pushes sub-screens above the shell
        GoRoute(
          path: RouteNames.provider,
          name: RouteNames.providerName,
          pageBuilder: (context, state) => _noTransitionPage(
            key: state.pageKey,
            child: const ProviderDashboard(),
          ),
          routes: [

            // Provider earnings — breaks out of shell for full-screen focus
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

            // Provider listings — same pattern
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

// ---------------------------------------------------------------------------
// Page transition helpers
// ---------------------------------------------------------------------------

// No animation — intentional for tab switches.
// Instant feels snappier; animated tab switches look jittery.
Page<void> _noTransitionPage({required LocalKey key, required Widget child}) {
  return NoTransitionPage<void>(key: key, child: child);
}

// Fade in — neutral and clean. Good for splash → home and any detail page
// where you want the screen to appear without a direction bias.
Page<void> _fadeTransitionPage({required LocalKey key, required Widget child}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: child,
      );
    },
  );
}

// Directional slide — each direction carries meaning:
//   left  → going deeper / forward into a sub-screen
//   right → returning (e.g. auth flow going back to login)
//   up    → modal / overlay feel (forms, bottom-sheet style pages)
Page<void> _slideTransitionPage({
  required LocalKey key,
  required Widget child,
  required AxisDirection direction,
}) {
  final startOffset = switch (direction) {
    AxisDirection.left  => const Offset(1.0, 0.0),
    AxisDirection.right => const Offset(-1.0, 0.0),
    AxisDirection.up    => const Offset(0.0, 1.0),
    AxisDirection.down  => const Offset(0.0, -1.0),
  };

  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: startOffset,
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        ),
        child: child,
      );
    },
  );
}

// ---------------------------------------------------------------------------
// GoRouterRefreshStream
// ---------------------------------------------------------------------------

// Bridges a Dart Stream to ChangeNotifier so GoRouter knows to re-run
// redirect() whenever the stream emits. Without this wiring, logging out
// wouldn't bounce the user back to login until their next navigation tap.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}