import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'core/routes/app_router.dart';
import 'firebase_options.dart';

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