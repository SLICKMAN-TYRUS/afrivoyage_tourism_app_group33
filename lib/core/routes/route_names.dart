// All route paths and names live here — one place, no scattered magic strings.
// If a route ever changes, you only fix it in this file.
//
// Usage:
//   context.go(RouteNames.home);
//   context.goNamed(RouteNames.loginName);
//   context.pushNamed(RouteNames.destinationDetailName,
//       pathParameters: {'destinationId': id});

abstract final class RouteNames {
  RouteNames._();

  // ---------------------------------------------------------------------------
  // Full paths — use these with context.go()
  // ---------------------------------------------------------------------------

  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String destinations = '/destinations';
  static const String trips = '/trips';
  static const String profile = '/profile';

  // Segments are relative — GoRouter appends them to the parent path.
  // They're separate constants so the router definition stays readable.
  static const String destinationDetailSegment = ':destinationId';
  static const String createTripSegment = 'create';
  static const String tripDetailSegment = ':tripId';
  static const String settingsSegment = 'settings';

  // Helper methods for paths that need an ID injected.
  // Way cleaner than building strings inline all over the codebase.
  static String destinationDetail(String id) => '$destinations/$id';
  static String tripDetail(String id) => '$trips/$id';

  // Static paths for the sub-routes that don't need dynamic segments
  static const String createTrip = '$trips/create';
  static const String settings = '$profile/settings';

  // ---------------------------------------------------------------------------
  // Named routes — use these with context.goNamed() / context.pushNamed()
  // ---------------------------------------------------------------------------
  // Prefer named navigation over path strings where possible.
  // If the path changes, named routes still work without touching every caller.

  static const String splashName = 'splash';
  static const String loginName = 'login';
  static const String registerName = 'register';
  static const String forgotPasswordName = 'forgotPassword';
  static const String homeName = 'home';
  static const String destinationsName = 'destinations';
  static const String destinationDetailName = 'destinationDetail';
  static const String tripsName = 'trips';
  static const String tripDetailName = 'tripDetail';
  static const String createTripName = 'createTrip';
  static const String profileName = 'profile';
  static const String settingsName = 'settings';
}