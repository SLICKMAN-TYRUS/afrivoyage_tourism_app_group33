import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';
import '../../features/auth/presentation/pages/splash_screen.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/destinations/presentation/pages/destinations_page.dart';
import '../../features/destinations/presentation/pages/destination_detail_page.dart';
import '../../features/trips/presentation/pages/trips_page.dart';
import '../../features/trips/presentation/pages/trip_detail_page.dart';
import '../../features/trips/presentation/pages/create_trip_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/settings_page.dart';
import '../../features/shell/presentation/pages/main_shell_page.dart';
import '../observers/router_observer.dart';
import 'error_page.dart';

// ---------------------------------------------------------------------------
// Navigator keys
// ---------------------------------------------------------------------------

// Two keys because we have two navigation stacks:
// - rootNavigatorKey  → full-screen routes (auth, splash, detail pages)
// - shellNavigatorKey → the bottom-nav tabs (home, destinations, trips, profile)
//
// Without this split, pressing back from a detail page would exit the shell
// entirely instead of just popping the detail. Annoying bug to debug if you
// miss it early on.
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

// ---------------------------------------------------------------------------
// Auth stream
// ---------------------------------------------------------------------------

// GoRouter needs a stream it can listen to so it knows when to re-run redirect().
// Firebase's authStateChanges() is perfect for this.
Stream<User?> get _authStream => FirebaseAuth.instance.authStateChanges();

// ---------------------------------------------------------------------------
// appRouter
// ---------------------------------------------------------------------------

// This is the single GoRouter instance the whole app uses.
// Route tree:
//
//   /splash
//   /login
//   /register
//   /forgot-password
//   /shell  ← ShellRoute (bottom nav lives here)
//     /home
//     /destinations
//       /:destinationId   ← pushed above shell, so the nav bar hides
//     /trips
//       /create           ← same, slides up like a modal
//       /:tripId
//     /profile
//       /settings
//
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RouteNames.splash,

  // Handy during development — prints every navigation event to the console.
  // Flip this to false before submitting.
  debugLogDiagnostics: true,

  observers: [RouterObserver()],

  // ---------------------------------------------------------------------------
  // Auth guard
  // ---------------------------------------------------------------------------
  // Called on every navigation AND whenever _authStream fires a new event.
  // Return a path to redirect, or null to let the navigation go through.
  redirect: (BuildContext context, GoRouterState state) {
    final user = FirebaseAuth.instance.currentUser;

    final onAuthFlow = {
      RouteNames.login,
      RouteNames.register,
      RouteNames.forgotPassword,
      RouteNames.splash,
    }.contains(state.matchedLocation);

    // Not logged in and trying to open a protected screen → send to login
    if (user == null && !onAuthFlow) return RouteNames.login;

    // Already logged in but stuck on the login screen → skip to home
    // (We leave splash out of this so it can do its own routing logic)
    if (user != null && onAuthFlow &&
        state.matchedLocation != RouteNames.splash) {
      return RouteNames.home;
    }

    return null; // all good, let it through
  },

  // Re-run redirect() whenever the auth state changes (login / logout)
  refreshListenable: GoRouterRefreshStream(_authStream),

  errorBuilder: (context, state) => ErrorPage(error: state.error),

  // ---------------------------------------------------------------------------
  // Routes
  // ---------------------------------------------------------------------------
  routes: [
    // Splash — first thing the user sees while Firebase warms up
    GoRoute(
      path: RouteNames.splash,
      name: RouteNames.splashName,
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => _fadeTransitionPage(
        key: state.pageKey,
        child: const SplashScreen(),
      ),
    ),

    // Login — slides in from the right (feels like going "forward")
    GoRoute(
      path: RouteNames.login,
      name: RouteNames.loginName,
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => _slideTransitionPage(
        key: state.pageKey,
        child: const LoginPage(),
        direction: AxisDirection.right,
      ),
    ),

    // Register — slides in from the left (opposite of login, like a branch)
    GoRoute(
      path: RouteNames.register,
      name: RouteNames.registerName,
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => _slideTransitionPage(
        key: state.pageKey,
        child: const RegisterPage(),
        direction: AxisDirection.left,
      ),
    ),

    // Forgot password — slides up like a sheet, feels less permanent
    GoRoute(
      path: RouteNames.forgotPassword,
      name: RouteNames.forgotPasswordName,
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => _slideTransitionPage(
        key: state.pageKey,
        child: const ForgotPasswordPage(),
        direction: AxisDirection.up,
      ),
    ),

    // Shell — wraps the four main tabs with the bottom navigation bar
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainShellPage(child: child),
      routes: [
        // Home tab — no transition, instant switch feels snappier for tabs
        GoRoute(
          path: RouteNames.home,
          name: RouteNames.homeName,
          pageBuilder: (context, state) =>
              _noTransitionPage(key: state.pageKey, child: const HomePage()),
        ),

        // Destinations tab
        GoRoute(
          path: RouteNames.destinations,
          name: RouteNames.destinationsName,
          pageBuilder: (context, state) => _noTransitionPage(
            key: state.pageKey,
            child: const DestinationsPage(),
          ),
          routes: [
            // Detail page breaks out of the shell so the bottom nav hides —
            // gives it that immersive full-screen feel
            GoRoute(
              path: RouteNames.destinationDetailSegment,
              name: RouteNames.destinationDetailName,
              parentNavigatorKey: _rootNavigatorKey,
              pageBuilder: (context, state) {
                final id = state.pathParameters['destinationId']!;
                return _fadeTransitionPage(
                  key: state.pageKey,
                  child: DestinationDetailPage(destinationId: id),
                );
              },
            ),
          ],
        ),

        // Trips tab
        GoRoute(
          path: RouteNames.trips,
          name: RouteNames.tripsName,
          pageBuilder: (context, state) =>
              _noTransitionPage(key: state.pageKey, child: const TripsPage()),
          routes: [
            // Create trip slides up — modal-style makes sense for a form
            GoRoute(
              path: RouteNames.createTripSegment,
              name: RouteNames.createTripName,
              parentNavigatorKey: _rootNavigatorKey,
              pageBuilder: (context, state) => _slideTransitionPage(
                key: state.pageKey,
                child: const CreateTripPage(),
                direction: AxisDirection.up,
              ),
            ),
            // Trip detail — same full-screen break as destination detail
            GoRoute(
              path: RouteNames.tripDetailSegment,
              name: RouteNames.tripDetailName,
              parentNavigatorKey: _rootNavigatorKey,
              pageBuilder: (context, state) {
                final id = state.pathParameters['tripId']!;
                return _fadeTransitionPage(
                  key: state.pageKey,
                  child: TripDetailPage(tripId: id),
                );
              },
            ),
          ],
        ),

        // Profile tab
        GoRoute(
          path: RouteNames.profile,
          name: RouteNames.profileName,
          pageBuilder: (context, state) =>
              _noTransitionPage(key: state.pageKey, child: const ProfilePage()),
          routes: [
            // Settings pushes above the shell — cleaner than keeping the nav bar
            GoRoute(
              path: RouteNames.settingsSegment,
              name: RouteNames.settingsName,
              parentNavigatorKey: _rootNavigatorKey,
              pageBuilder: (context, state) => _slideTransitionPage(
                key: state.pageKey,
                child: const SettingsPage(),
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

// No animation — best for tab switches. Instant feel is intentional here;
// animations between tabs look jittery and slow the app down mentally.
Page<void> _noTransitionPage({required LocalKey key, required Widget child}) {
  return NoTransitionPage<void>(key: key, child: child);
}

// Fade in — clean and neutral. Good for splash → home and detail pages
// where you want presence without direction bias.
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
//   left  → going deeper / forward
//   right → going back (auth screen returning to login)
//   up    → modal / overlay (forms, forgot password)
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
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: startOffset,
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      );
    },
  );
}

// ---------------------------------------------------------------------------
// GoRouterRefreshStream
// ---------------------------------------------------------------------------

// Bridges a Stream to ChangeNotifier so GoRouter knows to re-run redirect()
// when the stream emits. Without this, logging out wouldn't kick the user
// back to the login screen until the next navigation event.
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