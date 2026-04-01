<<<<<<< HEAD
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
                        color: Colors.green.withAlpha((0.2 * 255).toInt()),
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
=======
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/route_names.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../blocs/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(authRepository: AuthRepository()),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          final l10n = AppLocalizations.of(context)!;
          if (state is AuthAuthenticated) {
            if (state.accountType == 'provider') {
              context.go(RouteNames.provider);
            } else {
              context.go(RouteNames.home);
            }
          } else if (state is PasswordResetSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    '${l10n.passwordResetSentPrefix} ${state.email}'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
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
        child: Builder(builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // ── Top section — logo + title ──────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on,
                          size: 44,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        l10n.appTitle,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.appTagline,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),

                      // ── Tab bar ───────────────────────────
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.grey,
                          labelStyle: const TextStyle(
                              fontWeight: FontWeight.w600),
                          tabs: [
                            Tab(text: l10n.login),
                            Tab(text: l10n.signUp),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Tab views ─────────────────────────────────
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      _LoginForm(),
                      _SignUpForm(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
        }),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Login form
// ══════════════════════════════════════════════════════════════

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),

            // Email
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return l10n.emailRequired;
                }
                if (!validateEmail(v)) {
                  return l10n.enterValidEmail;
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Password
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(context),
              decoration: InputDecoration(
                labelText: l10n.password,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: () =>
                      setState(() => _obscure = !_obscure),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return l10n.passwordRequired;
                }
                return null;
              },
            ),

            // Forgot password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _showForgotPassword(context),
                child: Text(l10n.forgotPassword,
                    style: const TextStyle(fontSize: 12)),
              ),
            ),

            const SizedBox(height: 4),

            // Login button
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) => ElevatedButton(
                onPressed:
                    state is AuthLoading ? null : () => _submit(context),
                child: state is AuthLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(l10n.login),
              ),
            ),
            const SizedBox(height: 20),

            // Divider
            _orDivider(l10n),
            const SizedBox(height: 20),

            // Google
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) => OutlinedButton.icon(
                onPressed: state is AuthLoading
                    ? null
                    : () => context
                        .read<AuthBloc>()
                        .add(LoginWithGoogle()),
                icon: const Icon(Icons.g_mobiledata, size: 26),
                label: Text(l10n.continueWithGoogle),
              ),
            ),
            const SizedBox(height: 24),

            _termsText(l10n),
          ],
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState?.validate() != true) return;
    context.read<AuthBloc>().add(
          LoginWithEmail(
            _emailCtrl.text.trim(),
            _passwordCtrl.text,
          ),
        );
  }

  void _showForgotPassword(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ctrl = TextEditingController(text: _emailCtrl.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.resetPassword),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.resetPasswordHint),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: l10n.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () {
              if (validateEmail(ctrl.text)) {
                context
                    .read<AuthBloc>()
                    .add(SendPasswordReset(ctrl.text.trim()));
                Navigator.pop(ctx);
              }
            },
            child: Text(l10n.sendResetLink),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Sign Up form
// ══════════════════════════════════════════════════════════════

class _SignUpForm extends StatefulWidget {
  const _SignUpForm();

  @override
  State<_SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<_SignUpForm> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  DateTime? _dateOfBirth;
  String _accountType = 'tourist';
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;

  // Password strength
  int get _passwordStrength {
    final p = _passwordCtrl.text;
    int score = 0;
    if (p.length >= 8) score++;
    if (p.contains(RegExp(r'[A-Z]'))) score++;
    if (p.contains(RegExp(r'[a-z]'))) score++;
    if (p.contains(RegExp(r'[0-9]'))) score++;
    if (p.contains(RegExp(r'[!@#\$&*~%^()_\-+=\[\]{};:,.<>?]'))) score++;
    return score;
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 4),

            // ── Account type ────────────────────────────────
            _fieldLabel(l10n.iAma),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _accountTypeOption(
                    value: 'tourist',
                    icon: Icons.backpack_outlined,
                    label: l10n.tourist,
                    subtitle: l10n.touristSubtitle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _accountTypeOption(
                    value: 'provider',
                    icon: Icons.tour_outlined,
                    label: l10n.provider,
                    subtitle: l10n.providerSubtitle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Full name ───────────────────────────────────
            _fieldLabel(l10n.fullName),
            const SizedBox(height: 6),
            TextFormField(
              controller: _fullNameCtrl,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: l10n.fullNameHint,
                prefixIcon: const Icon(Icons.person_outline),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return l10n.fullNameRequired;
                }
                if (v.trim().split(' ').length < 2) {
                  return l10n.enterFirstAndLastName;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── Phone number ────────────────────────────────
            _fieldLabel(l10n.phoneNumber),
            const SizedBox(height: 6),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: l10n.phoneHint,
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return l10n.phoneRequired;
                }
                if (!validatePhone(v)) {
                  return l10n.enterValidPhone;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── Date of birth ───────────────────────────────
            _fieldLabel(l10n.dateOfBirth),
            const SizedBox(height: 6),
            InkWell(
              onTap: () => _pickDateOfBirth(l10n),
              borderRadius: BorderRadius.circular(10),
              child: InputDecorator(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.cake_outlined),
                  suffixIcon: Icon(Icons.calendar_month, size: 18),
                ),
                child: Text(
                  _dateOfBirth != null
                      ? _formatDate(_dateOfBirth!)
                      : l10n.selectDateOfBirth,
                  style: TextStyle(
                    color: _dateOfBirth != null
                        ? null
                        : Colors.grey[500],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Email ───────────────────────────────────────
            _fieldLabel(l10n.emailAddress),
            const SizedBox(height: 6),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: l10n.emailHint,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return l10n.emailRequired;
                }
                if (!validateEmail(v)) {
                  return l10n.enterValidEmail;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── Password ────────────────────────────────────
            _fieldLabel(l10n.password),
            const SizedBox(height: 6),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscurePass,
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: l10n.passwordHint,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePass
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: () =>
                      setState(() => _obscurePass = !_obscurePass),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return l10n.passwordRequired;
                }
                if (v.length < 8) {
                  return l10n.passwordMinLength;
                }
                if (!v.contains(RegExp(r'[A-Z]'))) {
                  return l10n.includeUppercase;
                }
                if (!v.contains(RegExp(r'[0-9]'))) {
                  return l10n.includeNumber;
                }
                return null;
              },
            ),
            // Password strength indicator
            if (_passwordCtrl.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              _passwordStrengthBar(l10n),
            ],
            const SizedBox(height: 16),

            // ── Confirm password ────────────────────────────
            _fieldLabel(l10n.confirmPassword),
            const SizedBox(height: 6),
            TextFormField(
              controller: _confirmCtrl,
              obscureText: _obscureConfirm,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(context),
              decoration: InputDecoration(
                hintText: l10n.reEnterPassword,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: () => setState(
                      () => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return l10n.pleaseConfirmPassword;
                }
                if (v != _passwordCtrl.text) {
                  return l10n.passwordsDoNotMatch;
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // ── Terms checkbox ──────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _agreedToTerms,
                  onChanged: (v) =>
                      setState(() => _agreedToTerms = v ?? false),
                  activeColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(
                        () => _agreedToTerms = !_agreedToTerms),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 13),
                          children: [
                            TextSpan(text: '${l10n.iAgreeTo} '),
                            TextSpan(
                              text: l10n.termsOfService,
                              style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600),
                            ),
                            TextSpan(text: ' ${l10n.and} '),
                            TextSpan(
                              text: l10n.privacyPolicy,
                              style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Create account button ───────────────────────
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) => ElevatedButton(
                onPressed: state is AuthLoading
                    ? null
                    : () => _submit(context),
                child: state is AuthLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(l10n.createAccount),
              ),
            ),
            const SizedBox(height: 20),

            _orDivider(l10n),
            const SizedBox(height: 20),

            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) => OutlinedButton.icon(
                onPressed: state is AuthLoading
                    ? null
                    : () => context
                        .read<AuthBloc>()
                        .add(LoginWithGoogle()),
                icon: const Icon(Icons.g_mobiledata, size: 26),
                label: Text(l10n.signUpWithGoogle),
              ),
            ),
            const SizedBox(height: 24),

            _termsText(l10n),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────

  Widget _accountTypeOption({
    required String value,
    required IconData icon,
    required String label,
    required String subtitle,
  }) {
    final selected = _accountType == value;
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: () => setState(() => _accountType = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? primary.withValues(alpha: 0.1) : Colors.transparent,
          border: Border.all(
            color: selected ? primary : Colors.grey.shade400,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 28, color: selected ? primary : Colors.grey),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: selected ? primary : null,
                    fontSize: 13)),
            const SizedBox(height: 2),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 10, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600),
      );

  Widget _passwordStrengthBar(AppLocalizations l10n) {
    final strength = _passwordStrength;
    final colors = [Colors.red, Colors.red, Colors.orange, Colors.yellow, Colors.green];
    final labels = [
      l10n.strengthVeryWeak,
      l10n.strengthWeak,
      l10n.strengthFair,
      l10n.strengthGood,
      l10n.strengthStrong,
    ];
    final color = colors[strength.clamp(0, 4)];
    final label = labels[strength.clamp(0, 4)];

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (strength / 5).clamp(0.05, 1.0),
              backgroundColor: Colors.grey.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 5,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Future<void> _pickDateOfBirth(AppLocalizations l10n) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20),
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year - 13),
      helpText: l10n.selectDateOfBirthHelper,
    );
    if (date != null) setState(() => _dateOfBirth = date);
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  void _submit(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_formKey.currentState?.validate() != true) return;

    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.selectDobSnackbar),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.agreeToTermsSnackbar),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
          SignUpWithProfile(
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text,
            fullName: _fullNameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            dateOfBirth: _formatDate(_dateOfBirth!),
            accountType: _accountType,
          ),
        );
  }
}

// ── Shared helpers ─────────────────────────────────────────────

Widget _orDivider(AppLocalizations l10n) => Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[400])),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(l10n.or, style: TextStyle(color: Colors.grey[500])),
        ),
        Expanded(child: Divider(color: Colors.grey[400])),
      ],
    );

Widget _termsText(AppLocalizations l10n) => Text(
      l10n.byContinuing,
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.grey[500], fontSize: 11),
    );
>>>>>>> 29e8a2ecd0fb79f8abafa321d1f4041ac6a965e7
