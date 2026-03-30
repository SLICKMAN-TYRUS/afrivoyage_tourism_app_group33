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
                    'Password reset email sent to ${state.email}'),
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
                  return '${l10n.emailAddress} is required';
                }
                if (!validateEmail(v)) {
                  return 'Enter a valid email address';
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
                  return '${l10n.password} is required';
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
            _orDivider(),
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

            _termsText(),
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
    final ctrl = TextEditingController(text: _emailCtrl.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Enter your email address and we will send you a link to reset your password.'),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email address',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (validateEmail(ctrl.text)) {
                context
                    .read<AuthBloc>()
                    .add(SendPasswordReset(ctrl.text.trim()));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Send Reset Link'),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 4),

            // ── Account type ────────────────────────────────
            _fieldLabel('I am a'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _accountTypeOption(
                    value: 'tourist',
                    icon: Icons.backpack_outlined,
                    label: 'Tourist',
                    subtitle: 'Explore & book experiences',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _accountTypeOption(
                    value: 'provider',
                    icon: Icons.tour_outlined,
                    label: 'Provider',
                    subtitle: 'List & manage experiences',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Full name ───────────────────────────────────
            _fieldLabel('Full Name'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _fullNameCtrl,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'e.g. Jean-Baptiste Uwimana',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Full name is required';
                }
                if (v.trim().split(' ').length < 2) {
                  return 'Please enter your first and last name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── Phone number ────────────────────────────────
            _fieldLabel('Phone Number'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'e.g. +250 788 123 456',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Phone number is required';
                }
                if (!validatePhone(v)) {
                  return 'Enter a valid phone number (9-15 digits)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── Date of birth ───────────────────────────────
            _fieldLabel('Date of Birth'),
            const SizedBox(height: 6),
            InkWell(
              onTap: _pickDateOfBirth,
              borderRadius: BorderRadius.circular(10),
              child: InputDecorator(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.cake_outlined),
                  suffixIcon: const Icon(Icons.calendar_month,
                      size: 18),
                  errorText: _dateOfBirth == null &&
                          _formKey.currentState != null
                      ? null
                      : null,
                ),
                child: Text(
                  _dateOfBirth != null
                      ? _formatDate(_dateOfBirth!)
                      : 'Select your date of birth',
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
            _fieldLabel('Email Address'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'e.g. jean@example.com',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Email is required';
                }
                if (!validateEmail(v)) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── Password ────────────────────────────────────
            _fieldLabel('Password'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscurePass,
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'At least 8 characters',
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
                  return 'Password is required';
                }
                if (v.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                if (!v.contains(RegExp(r'[A-Z]'))) {
                  return 'Include at least one uppercase letter';
                }
                if (!v.contains(RegExp(r'[0-9]'))) {
                  return 'Include at least one number';
                }
                return null;
              },
            ),
            // Password strength indicator
            if (_passwordCtrl.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              _passwordStrengthBar(),
            ],
            const SizedBox(height: 16),

            // ── Confirm password ────────────────────────────
            _fieldLabel('Confirm Password'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _confirmCtrl,
              obscureText: _obscureConfirm,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(context),
              decoration: InputDecoration(
                hintText: 'Re-enter your password',
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
                  return 'Please confirm your password';
                }
                if (v != _passwordCtrl.text) {
                  return 'Passwords do not match';
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
                          children: const [
                            TextSpan(
                                text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600),
                            ),
                            TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
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
                    : const Text('Create Account'),
              ),
            ),
            const SizedBox(height: 20),

            _orDivider(),
            const SizedBox(height: 20),

            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) => OutlinedButton.icon(
                onPressed: state is AuthLoading
                    ? null
                    : () => context
                        .read<AuthBloc>()
                        .add(LoginWithGoogle()),
                icon: const Icon(Icons.g_mobiledata, size: 26),
                label: const Text('Sign up with Google'),
              ),
            ),
            const SizedBox(height: 24),

            _termsText(),
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

  Widget _passwordStrengthBar() {
    final strength = _passwordStrength;
    final colors = [Colors.red, Colors.red, Colors.orange, Colors.yellow, Colors.green];
    final labels = ['Very weak', 'Weak', 'Fair', 'Good', 'Strong'];
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

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20),
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year - 13), // must be at least 13
      helpText: 'Select Date of Birth',
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
    if (_formKey.currentState?.validate() != true) return;

    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your date of birth'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please agree to the Terms of Service to continue'),
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

Widget _orDivider() => Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[400])),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child:
              Text('or', style: TextStyle(color: Colors.grey[500])),
        ),
        Expanded(child: Divider(color: Colors.grey[400])),
      ],
    );

Widget _termsText() => Text(
      'By continuing, you agree to our Terms of Service and Privacy Policy.',
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.grey[500], fontSize: 11),
    );
