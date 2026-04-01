import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/cubits/settings_cubit.dart';
import '../../../core/routes/route_names.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared/theme/theme_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
            padding: const EdgeInsets.all(16),
            children: [
              _HeaderCard(
                title: l10n.settings,
                subtitle: l10n.appTagline,
              ),
              const SizedBox(height: 16),
              _SectionLabel(text: l10n.preferences),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.dark_mode_outlined),
                      title: Text(l10n.darkMode),
                      subtitle: Text(l10n.darkModeToggle),
                      value: isDark,
                      onChanged: (value) {
                        context.read<ThemeCubit>().setThemeMode(
                              value ? ThemeMode.dark : ThemeMode.light,
                            );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.language_outlined),
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
                          DropdownMenuItem(
                            value: 'en',
                            child: Text('English'),
                          ),
                          DropdownMenuItem(
                            value: 'fr',
                            child: Text('Français'),
                          ),
                          DropdownMenuItem(
                            value: 'rw',
                            child: Text('Kinyarwanda'),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.offline_bolt_outlined),
                      title: Text(l10n.offlineMode),
                      subtitle: Text(l10n.offlineModeSubtitle),
                      value: settings.offlineMode,
                      onChanged: (value) {
                        context.read<SettingsCubit>().toggleOfflineMode(value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionLabel(text: l10n.account),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(l10n.myProfile),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () => _showProfileDialog(context),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.bookmark_outline),
                      title: Text(l10n.myBookings),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () => context.go(RouteNames.bookings),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.help_outline),
                      title: Text(l10n.helpSupport),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () => _showSupportDialog(context),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: Text(l10n.aboutAfriVoyage),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () => _showAboutDialog(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: Text(
                    l10n.logout,
                    style: const TextStyle(color: Colors.red),
                  ),
                  onTap: () => _confirmLogout(context),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'AfriVoyage v1.0.0 · Group 33',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
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

  void _showProfileDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    final name =
        user?.displayName?.isNotEmpty == true ? user!.displayName! : 'User';
    final email = user?.email ?? '—';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.myProfile),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person),
              title: Text(name),
              subtitle: Text(l10n.touristAccount),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.email),
              title: Text(email),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.helpSupport),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.contactUs,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('📧  support@afrivoyage.rw'),
            const SizedBox(height: 4),
            const Text('📞  +250 788 123 456'),
            const SizedBox(height: 4),
            const Text('⏰  Mon–Fri  8 am – 6 pm (CAT)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'AfriVoyage',
      applicationVersion: '1.0.0',
      applicationLegalese:
          '© 2026 AfriVoyage Group 33\nConnecting tourists with authentic Rwanda experiences.',
    );
  }

  void _confirmLogout(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await AuthRepository().signOut();
              if (context.mounted) {
                context.go(RouteNames.login);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.settings, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey[600],
          letterSpacing: 0.9,
        ),
      ),
    );
  }
}
