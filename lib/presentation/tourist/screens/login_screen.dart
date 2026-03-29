import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../data/repositories/auth_repository.dart';
import '../blocs/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(authRepository: AuthRepository()),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/home');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // ── Logo ─────────────────────────────────────
                  Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on,
                        size: 46,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'AfriVoyage',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Discover authentic Rwanda experiences',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 36),

                  // ── Demo / quick-access banner ────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      border: Border.all(
                          color: Colors.green.withValues(alpha: 0.4)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: Colors.green, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text('Demo Mode',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                      fontSize: 13)),
                              const SizedBox(height: 2),
                              Text(
                                'Skip login to explore the app with static data.',
                                style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/home'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          child: const Text('Enter',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Login / Sign Up toggle ────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _isLogin = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12),
                              decoration: BoxDecoration(
                                color: _isLogin
                                    ? Colors.green
                                    : Colors.transparent,
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Login',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _isLogin
                                      ? Colors.white
                                      : Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _isLogin = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12),
                              decoration: BoxDecoration(
                                color: !_isLogin
                                    ? Colors.green
                                    : Colors.transparent,
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Sign Up',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: !_isLogin
                                      ? Colors.white
                                      : Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Email ─────────────────────────────────────
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Password ──────────────────────────────────
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () => setState(() =>
                            _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  if (_isLogin) ...[
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('Forgot password?',
                            style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ] else
                    const SizedBox(height: 20),

                  // ── Submit button ─────────────────────────────
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state is AuthLoading
                            ? null
                            : () {
                                if (_isLogin) {
                                  context.read<AuthBloc>().add(
                                        LoginWithEmail(
                                          _emailController.text
                                              .trim(),
                                          _passwordController.text,
                                        ),
                                      );
                                } else {
                                  context.read<AuthBloc>().add(
                                        SignUpWithEmail(
                                          _emailController.text
                                              .trim(),
                                          _passwordController.text,
                                        ),
                                      );
                                }
                              },
                        child: state is AuthLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(_isLogin
                                ? 'Login'
                                : 'Create Account'),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // ── Or divider ────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                          child: Divider(color: Colors.grey[400])),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14),
                        child: Text('or',
                            style: TextStyle(
                                color: Colors.grey[500])),
                      ),
                      Expanded(
                          child: Divider(color: Colors.grey[400])),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Google Sign In ────────────────────────────
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return OutlinedButton.icon(
                        onPressed: state is AuthLoading
                            ? null
                            : () {
                                context
                                    .read<AuthBloc>()
                                    .add(LoginWithGoogle());
                              },
                        icon: const Icon(Icons.g_mobiledata,
                            size: 26),
                        label: const Text('Continue with Google'),
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  // ── Terms ─────────────────────────────────────
                  Text(
                    'By continuing, you agree to our Terms of Service and Privacy Policy.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.grey[500], fontSize: 11),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
