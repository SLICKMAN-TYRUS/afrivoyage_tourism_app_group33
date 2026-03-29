import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/auth_repository.dart';
import '../../presentation/tourist/blocs/auth/auth_bloc.dart';
import '../../presentation/tourist/screens/login_screen.dart';
import '../../presentation/tourist/screens/home_screen.dart';
import '../../presentation/tourist/screens/booking_confirmation_screen.dart';
import '../../presentation/tourist/screens/impact_dashboard_screen.dart';
import '../../presentation/provider/screens/provider_dashboard.dart';
import '../../presentation/provider/screens/provider_listings.dart';
import '../../presentation/provider/screens/provider_earnings.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    // Auth Routes
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => BlocProvider(
        create: (context) => AuthBloc(authRepository: AuthRepository()),
        child: const LoginScreen(),
      ),
    ),

    // Tourist Routes
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/booking/:id',
      name: 'booking',
      builder: (context, state) {
        final experienceId = state.pathParameters['id']!;
        return BookingScreen(experienceId: experienceId);
      },
    ),
    GoRoute(
      path: '/impact',
      name: 'impact',
      builder: (context, state) => const ImpactScreen(),
    ),

    // Provider Routes
    GoRoute(
      path: '/provider',
      name: 'provider_dashboard',
      builder: (context, state) => const ProviderDashboard(),
    ),
    GoRoute(
      path: '/provider/listings',
      name: 'provider_listings',
      builder: (context, state) => const ProviderListings(),
    ),
    GoRoute(
      path: '/provider/earnings',
      name: 'provider_earnings',
      builder: (context, state) => const ProviderEarnings(),
    ),
  ],
);
