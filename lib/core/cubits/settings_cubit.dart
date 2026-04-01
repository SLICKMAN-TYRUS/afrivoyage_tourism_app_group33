import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState extends Equatable {
  final String language;
  final bool offlineMode;

  const SettingsState({
    this.language = 'en',
    this.offlineMode = false,
  });

  SettingsState copyWith({
    String? language,
    bool? offlineMode,
  }) {
    return SettingsState(
      language: language ?? this.language,
      offlineMode: offlineMode ?? this.offlineMode,
    );
  }

  @override
  List<Object?> get props => [language, offlineMode];
}

class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences _prefs;

  SettingsCubit(this._prefs) : super(const SettingsState()) {
    _loadSettings();
  }

  void _loadSettings() {
    final lang = _prefs.getString('language') ?? 'en';
    final offline = _prefs.getBool('offlineMode') ?? false;
    emit(SettingsState(language: lang, offlineMode: offline));
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
