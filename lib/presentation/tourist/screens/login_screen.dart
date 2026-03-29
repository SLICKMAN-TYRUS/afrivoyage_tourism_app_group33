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

  @override
  void dispose() {
    // always clean up controllers — small thing that matters for memory
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // BlocProvider here so AuthBloc is scoped to this screen only,
    // not leaked into the whole widget tree
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
                  const SizedBox(height: 48),

                  // Logo
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on,
                        size: 40,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'AfriVoyage',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Discover authentic Rwanda experiences',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 48),

                  // Login / Sign Up toggle
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isLogin = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _isLogin
                                    ? Colors.green
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Login',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color:
                                      _isLogin ? Colors.white : Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isLogin = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_isLogin
                                    ? Colors.green
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Sign Up',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color:
                                      !_isLogin ? Colors.white : Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Email field
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit button — disabled while loading so users can't double-tap
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state is AuthLoading
                            ? null
                            : () {
                                if (_isLogin) {
                                  context.read<AuthBloc>().add(
                                        LoginWithEmail(
                                          _emailController.text.trim(),
                                          _passwordController.text,
                                        ),
                                      );
                                } else {
                                  context.read<AuthBloc>().add(
                                        SignUpWithEmail(
                                          _emailController.text.trim(),
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
                            : Text(_isLogin ? 'Login' : 'Create Account'),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[700])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[700])),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Google Sign In
                  OutlinedButton.icon(
                    onPressed: () {
                      context.read<AuthBloc>().add(LoginWithGoogle());
                    },
                    icon: Image.network(
                      'https://www.google.com/favicon.ico',
                      height: 24,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.g_mobiledata),
                    ),
                    label: const Text('Continue with Google'),
                  ),
                  const SizedBox(height: 32),

                  // Terms
                  Text(
                    'By continuing, you agree to our Terms of Service and Privacy Policy',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}