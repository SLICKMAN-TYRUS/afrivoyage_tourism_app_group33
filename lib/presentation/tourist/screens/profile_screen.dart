import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afrivoyage/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../core/cubits/settings_cubit.dart';
import '../../../core/routes/route_names.dart';
import '../../../presentation/shared/theme/theme_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode = context.watch<ThemeCubit>().state;
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          return ListView(
            children: [
              // ── Theme ──────────────────────────────────────────
              SwitchListTile(
                title: Text(l10n.darkMode),
                subtitle: Text(l10n.darkModeSubtitle),
                value: isDark,
                onChanged: (value) {
                  context.read<ThemeCubit>().setThemeMode(
                        value ? ThemeMode.dark : ThemeMode.light,
                      );
                },
              ),

              // ── Language ───────────────────────────────────────
              ListTile(
                title: Text(l10n.language),
                subtitle: Text(_languageLabel(settings.language)),
                trailing: DropdownButton<String>(
                  value: settings.language,
                  underline: const SizedBox.shrink(),
                  onChanged: (value) {
                    if (value != null) {
                      context.read<SettingsCubit>().setLanguage(value);
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'fr', child: Text('Français')),
                    DropdownMenuItem(value: 'rw', child: Text('Kinyarwanda')),
                  ],
                ),
              ),

              // ── Offline Mode ───────────────────────────────────
              SwitchListTile(
                title: Text(l10n.offlineMode),
                subtitle: Text(l10n.offlineModeSubtitle),
                value: settings.offlineMode,
                onChanged: (value) {
                  context.read<SettingsCubit>().toggleOfflineMode(value);
                },
              ),

              const Divider(),

              // ── Account ────────────────────────────────────────
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(l10n.myProfile),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),

              ListTile(
                leading: const Icon(Icons.bookmark),
                title: Text(l10n.myBookings),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => context.go(RouteNames.bookings),
              ),

              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(
                  l10n.logout,
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    context.go(RouteNames.login);
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  String _languageLabel(String code) {
    switch (code) {
      case 'fr':
        return 'Français';
      case 'rw':
        return 'Kinyarwanda';
      default:
        return 'English';
    }
  }
}
