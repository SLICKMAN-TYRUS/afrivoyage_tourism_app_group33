import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:afrivoyage/core/routes/app_router.dart';
import 'package:afrivoyage/core/observers/app_bloc_observer.dart';
import 'package:afrivoyage/core/cubits/settings_cubit.dart';
import 'package:afrivoyage/presentation/shared/theme/theme_cubit.dart';
import 'package:afrivoyage/firebase_options.dart';
import 'package:afrivoyage/l10n/app_localizations.dart';
import 'package:afrivoyage/l10n/fallback_localizations.dart';

// Starting point of the whole app. Keep this file lean —
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase - Role 4
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _appRouter = AppRouter(); // Role 1 provides this

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AfriVoyage',
      theme: ThemeData(primarySwatch: Colors.green),
      routerConfig: _appRouter.config(),
    );
  }
}
