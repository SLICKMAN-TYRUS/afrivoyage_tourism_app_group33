import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import 'route_names.dart';

// Shown whenever GoRouter hits a route it doesn't recognize,
// or when something throws during navigation.
//
// Keeping this friendly matters — a raw red error screen makes
// the whole app feel broken even if only one route misbehaved.
class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key, this.error});

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pageNotFound)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Using an icon instead of an image keeps this self-contained —
              // no asset loading that could itself fail
              Icon(
                Icons.explore_off_rounded,
                size: 80,
                color: theme.colorScheme.primary.withAlpha((0.5 * 255).toInt()),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.oopsLostInAfrica,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                error?.toString() ?? l10n.pageNotFoundDesc,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha((0.6 * 255).toInt()),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Take them back to a known-good state rather than leaving them stuck
              ElevatedButton.icon(
                onPressed: () => context.go(RouteNames.home),
                icon: const Icon(Icons.home_rounded),
                label: Text(l10n.backToHome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
