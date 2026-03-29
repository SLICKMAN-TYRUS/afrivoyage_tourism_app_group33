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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(authRepository: AuthRepository()),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/home');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, size: 80, color: Colors.green),
                  const SizedBox(height: 16),
                  const Text('AfriVoyage', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => setState(() => _isLogin = true),
                        child: Text('Login', style: TextStyle(color: _isLogin ? Colors.green : Colors.grey)),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _isLogin = false),
                        child: Text('Sign Up', style: TextStyle(color: !_isLogin ? Colors.green : Colors.grey)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_isLogin) {
                          context.read<AuthBloc>().add(LoginWithEmail(
                            _emailController.text,
                            _passwordController.text,
                          ));
                        } else {
                          context.read<AuthBloc>().add(SignUpWithEmail(
                            _emailController.text,
                            _passwordController.text,
                          ));
                        }
                      },
                      child: Text(_isLogin ? 'Login' : 'Sign Up'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Or continue with'),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => context.read<AuthBloc>().add(LoginWithGoogle()),
                    icon: const Icon(Icons.login),
                    label: const Text('Google'),
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
