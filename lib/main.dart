import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:afrivoyage/core/routes/app_router.dart';
import 'package:afrivoyage/core/observers/app_bloc_observer.dart';
import 'package:afrivoyage/presentation/shared/theme/theme_cubit.dart';
// keeping DefaultFirebaseOptions from their branch — more explicit and safer
import 'package:afrivoyage/firebase_options.dart';

// Starting point of the whole app. Keep this file lean —
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait only. Landscape on a travel app just looks weird —
  // nobody is scrolling destination cards sideways.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar so hero images bleed all the way to the top edge.
  // Looks a lot more premium with destination photos.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Firebase has to go first — pretty much everything else depends on it.
  // Using DefaultFirebaseOptions so it works correctly on both Android and iOS.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Load prefs before runApp, not inside the widget tree.
  // If we await it later we get a flash of the wrong theme on startup — not great.
  final sharedPreferences = await SharedPreferences.getInstance();

  // Wires up our BLoC observer so every state change prints to the debug console.
  // Makes tracking down weird UI bugs a lot less painful.
  Bloc.observer = AppBlocObserver();

  runApp(AfriVoyageApp(sharedPreferences: sharedPreferences));
}

class AfriVoyageApp extends StatelessWidget {
  const AfriVoyageApp({super.key, required this.sharedPreferences});

  final SharedPreferences sharedPreferences;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // ThemeCubit sits at the root so any screen can toggle the theme
        // without passing anything down the tree. It also reads the user's
        // saved preference from SharedPreferences on first build.
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit(sharedPreferences),
        ),

        // Add the team's BLoCs here as we wire things up.
        // Keep them here — not buried inside individual screens.
        // BlocProvider<AuthBloc>(create: (_) => AuthBloc()),
        // BlocProvider<ExperienceBloc>(create: (_) => ExperienceBloc()),
        // BlocProvider<ProviderBloc>(create: (_) => ProviderBloc()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'AfriVoyage',
            debugShowCheckedModeBanner: false,
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),

            // Comes straight from ThemeCubit which reads SharedPreferences —
            // user picks dark mode once, it sticks forever.
            themeMode: themeMode,

            routerConfig: appRouter,
          );
        },
      ),
    );
  }

  ThemeData _buildLightTheme() {
    // Deep forest green. Felt more "Africa" than the generic teal
    // everyone reaches for by default.
    const seedColor = Color(0xFF2E7D32);

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
        primary: seedColor,
        secondary: const Color(0xFFF57C00), // warm amber — think safari sunset
        surface: const Color(0xFFFAFAFA),
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),

      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent, // lets hero images shine through
        foregroundColor: Color(0xFF1B5E20),
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1B5E20),
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Color(0xFF2E7D32),
        unselectedItemColor: Color(0xFF9E9E9E),
        backgroundColor: Colors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),

      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: seedColor,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    // Slightly lighter green so it doesn't vanish against the dark background
    const seedColor = Color(0xFF66BB6A);

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
        primary: seedColor,
        secondary: const Color(0xFFFFB74D),
        surface: const Color(0xFF1C1C1E),
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF121212),

      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF66BB6A),
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF66BB6A),
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Color(0xFF66BB6A),
        unselectedItemColor: Color(0xFF757575),
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),

      cardTheme: CardThemeData(
        elevation: 2,
        color: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: seedColor,
          foregroundColor: Colors.black,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}