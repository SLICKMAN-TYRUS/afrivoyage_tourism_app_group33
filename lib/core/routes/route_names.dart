// All route paths and names live here — one source of truth, no magic strings
// scattered across the codebase. If a path changes, you fix it once, here.
//
// Usage:
//   context.go(RouteNames.home);
//   context.goNamed(RouteNames.loginName);
//   context.pushNamed(RouteNames.earningsName);

abstract final class RouteNames {
  RouteNames._();

  // ---------------------------------------------------------------------------
  // Full paths — use with context.go() / context.push()
  // ---------------------------------------------------------------------------

  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String settings = '/settings';
  static const String bookings = '/bookings';
  static const String impact = '/impact';
  static const String provider = '/provider';

  // Relative segments — GoRouter appends these to the parent route.
  // Kept separate so the router definition in app_router.dart stays clean.
  static const String earningsSegment = 'earnings';
  static const String listingsSegment = 'listings';

  // Full paths for the sub-routes (handy for context.go() calls)
  static const String earnings = '$provider/earnings';
  static const String listings = '$provider/listings';

  // ---------------------------------------------------------------------------
  // Named routes — prefer these with context.goNamed() / context.pushNamed()
  // ---------------------------------------------------------------------------
  // Named navigation survives path changes without touching every call site.

  static const String splashName = 'splash';
  static const String loginName = 'login';
  static const String homeName = 'home';
  static const String settingsName = 'settings';
  static const String bookingsName = 'bookings';
  static const String impactName = 'impact';
  static const String providerName = 'provider';
  static const String earningsName = 'earnings';
  static const String listingsName = 'listings';
}
