import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:afrivoyage/firebase_options.dart';
import 'package:afrivoyage/routes/app_router.dart';

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
