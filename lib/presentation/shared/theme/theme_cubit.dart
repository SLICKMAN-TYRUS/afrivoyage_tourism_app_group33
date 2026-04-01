// Place this file at: lib/presentation/shared/theme/theme_cubit.dart
// (sits right alongside the existing app_theme.dart your team already has)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// The key we write to SharedPreferences.
// Using a namespaced string avoids clashing if we add more prefs later.
const _kThemeModeKey = 'afrivoyage_theme_mode';

// Manages the app's ThemeMode and makes sure it survives restarts.
//
// The flow:
//   1. App cold-starts → SharedPreferences already loaded in main()
//   2. ThemeCubit reads the saved index → emits the right ThemeMode immediately
//   3. User changes theme → we emit the new mode AND write it to prefs
//   4. Next cold start → step 1 again, no flash of wrong theme
//
// Usage from any widget:
//   context.read<ThemeCubit>().toggleTheme();
//   context.read<ThemeCubit>().setThemeMode(ThemeMode.dark);
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._prefs) : super(_loadSavedMode(_prefs));

  final SharedPreferences _prefs;

  // Flips between light and dark. If the user is on system mode,
  // we treat that as light and switch to dark — feels more intuitive.
  void toggleTheme() {
    setThemeMode(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  void setLight()  => setThemeMode(ThemeMode.light);
  void setDark()   => setThemeMode(ThemeMode.dark);

  // Follow the device's own setting — useful if the user just wants
  // to stop thinking about it and let the phone decide.
  void setSystem() => setThemeMode(ThemeMode.system);

  // The one method everything else funnels through.
  // Emits the new state and writes to disk in one shot.
  void setThemeMode(ThemeMode mode) {
    emit(mode);
    _prefs.setInt(_kThemeModeKey, mode.index);
  }

  // Reads the saved index on startup. Defaults to system if nothing's stored —
  // reasonable first-launch default, respects the user's OS setting.
  static ThemeMode _loadSavedMode(SharedPreferences prefs) {
    final index = prefs.getInt(_kThemeModeKey);
    if (index == null) return ThemeMode.system;
    // clamp just in case someone tampers with the prefs file
    return ThemeMode.values[index.clamp(0, ThemeMode.values.length - 1)];
  }
}