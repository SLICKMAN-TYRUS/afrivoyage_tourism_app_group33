import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/cubits/settings_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            children: [
              // Theme Toggle
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Toggle between light and dark theme'),
                value: state.isDarkMode,
                onChanged: (value) {
                  context.read<SettingsCubit>().toggleTheme(value);
                },
              ),

              // Language Selection
              ListTile(
                title: const Text('Language'),
                subtitle: Text(state.language.toUpperCase()),
                trailing: DropdownButton<String>(
                  value: state.language,
                  onChanged: (value) {
                    if (value != null) {
                      context.read<SettingsCubit>().setLanguage(value);
                    }
                  },
                  items: ['en', 'fr', 'rw'].map((lang) {
                    return DropdownMenuItem(
                      value: lang,
                      child: Text(lang.toUpperCase()),
                    );
                  }).toList(),
                ),
              ),

              // Offline Mode
              SwitchListTile(
                title: const Text('Offline Mode'),
                subtitle: const Text('Enable offline access to bookings'),
                value: state.offlineMode,
                onChanged: (value) {
                  context.read<SettingsCubit>().toggleOfflineMode(value);
                },
              ),

              const Divider(),

              // User Info Section
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('My Profile'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to edit profile
                },
              ),

              ListTile(
                leading: const Icon(Icons.bookmark),
                title: const Text('My Bookings'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to bookings
                },
              ),

              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title:
                    const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () {
                  // Handle logout
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
