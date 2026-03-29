// Place this file at: lib/core/observers/app_bloc_observer.dart

import 'package:flutter_bloc/flutter_bloc.dart';

// Global BLoC observer — registered once in main() and then it silently
// watches every BLoC and Cubit in the app.
//
// In dev, this is invaluable: you can see exactly what event triggered
// which state change without adding print statements everywhere.
// In prod, swap debugPrint for a proper crash/analytics logger.
class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    debugPrint('[BLoC] Created → ${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    debugPrint('[BLoC] ${bloc.runtimeType} received: $event');
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    // Before → After makes it easy to spot unexpected state transitions
    debugPrint(
      '[BLoC] ${bloc.runtimeType}: '
      '${change.currentState} → ${change.nextState}',
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    // Errors in BLoCs are silent by default — this makes sure nothing
    // slips through without at least showing up in the console.
    debugPrint('[BLoC] ERROR in ${bloc.runtimeType}: $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    debugPrint('[BLoC] Closed → ${bloc.runtimeType}');
  }

  // ignore: avoid_print
  void debugPrint(String message) => print(message);
}