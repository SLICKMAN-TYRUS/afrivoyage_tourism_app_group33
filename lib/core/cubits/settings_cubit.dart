// import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// States (same as before)
class SettingsState extends Equatable {
  final bool isDarkMode;
  final String language;
  final bool offlineMode;

  const SettingsState({
    this.isDarkMode = false,
    this.language = 'en',
    this.offlineMode = false,
  });

  SettingsState copyWith({
    bool? isDarkMode,
    String? language,
    bool? offlineMode,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
      offlineMode: offlineMode ?? this.offlineMode,
    );
  }

  @override
  List<Object?> get props => [isDarkMode, language, offlineMode];
}

// Cubit - NOW WITH CONSTRUCTOR PARAMETER
class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences _prefs;

  // Constructor accepts prefs
  SettingsCubit(this._prefs) : super(const SettingsState()) {
    _loadSettings();
  }

  void _loadSettings() {
    final isDark = _prefs.getBool('isDarkMode') ?? false;
    final lang = _prefs.getString('language') ?? 'en';
    final offline = _prefs.getBool('offlineMode') ?? false;

    emit(SettingsState(
      isDarkMode: isDark,
      language: lang,
      offlineMode: offline,
    ));
  }

  Future<void> toggleTheme(bool isDark) async {
    await _prefs.setBool('isDarkMode', isDark);
    emit(state.copyWith(isDarkMode: isDark));
  }

  Future<void> setLanguage(String lang) async {
    await _prefs.setString('language', lang);
    emit(state.copyWith(language: lang));
  }

  Future<void> toggleOfflineMode(bool offline) async {
    await _prefs.setBool('offlineMode', offline);
    emit(state.copyWith(offlineMode: offline));
  }
}
