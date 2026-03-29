// Place this file at: lib/core/observers/router_observer.dart

import 'package:flutter/material.dart';

// Logs every navigation event to the debug console.
// Attach it to GoRouter via the observers list in app_router.dart.
//
// Right now it just prints — but when we hook up Firebase Analytics,
// this is the right place to send screen_view events instead of
// scattering analytics calls across every page's initState.
class RouterObserver extends NavigatorObserver {
  const RouterObserver();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log('PUSH', route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log('POP', route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    // Replace happens during redirect() — logging it helps us verify
    // the auth guard is sending users to the right screen.
    debugPrint(
      '[Router] REPLACE: ${oldRoute?.settings.name ?? '?'} → ${newRoute?.settings.name ?? '?'}',
    );
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log('REMOVE', route, previousRoute);
  }

  void _log(String action, Route<dynamic> route, Route<dynamic>? prev) {
    debugPrint(
      '[Router] $action: ${prev?.settings.name ?? 'none'} → '
      '${route.settings.name ?? route.runtimeType}',
    );
  }
}