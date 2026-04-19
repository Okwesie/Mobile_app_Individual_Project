import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adventure_logger/core/utils/app_router.dart';
import 'package:adventure_logger/core/utils/app_theme.dart';
import 'package:adventure_logger/features/auth/auth_provider.dart';
import 'package:adventure_logger/features/auth/widgets/google_sign_in_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.signUp(
      name: _nameCtrl.text,
      email: _emailCtrl.text,
      password: _passwordCtrl.text,
    );
    if (ok && mounted) {
      Navigator.pushReplacementNamed(context, AppRouter.shell);
    }
  }

  Future<void> _googleSignIn() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.signInWithGoogle();
    if (ok && mounted) {
      Navigator.pushReplacementNamed(context, AppRouter.shell);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Header ────────────────────────────────────────────────
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: AppTheme.headerGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(32, 48, 32, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 20),
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Create account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Start logging your adventures today.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Form ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                child: Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (auth.error != null) ...[
                            _ErrorBanner(message: auth.error!),
                            const SizedBox(height: 20),
                          ],

                          // Full name
                          _FieldLabel('Full name'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nameCtrl,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              hintText: 'e.g. Caleb Arthur',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Full name is required.';
                              }
                              if (v.trim().length < 2) {
                                return 'Name is too short.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Email
                          _FieldLabel('Email address'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autocorrect: false,
                            decoration: const InputDecoration(
                              hintText: 'you@example.com',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Email is required.';
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                  .hasMatch(v.trim())) {
                                return 'Enter a valid email address.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Password
                          _FieldLabel('Password'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscurePass,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              hintText: 'At least 8 characters',
                              prefixIcon:
                                  const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePass
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () => setState(
                                    () => _obscurePass = !_obscurePass),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Password is required.';
                              }
                              if (v.length < 8) {
                                return 'Password must be at least 8 characters.';
                              }
                              if (!RegExp(r'[A-Za-z]').hasMatch(v)) {
                                return 'Password must contain at least one letter.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Confirm password
                          _FieldLabel('Confirm password'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _confirmCtrl,
                            obscureText: _obscureConfirm,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            decoration: InputDecoration(
                              hintText: 'Re-enter your password',
                              prefixIcon:
                                  const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () => setState(() =>
                                    _obscureConfirm = !_obscureConfirm),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please confirm your password.';
                              }
                              if (v != _passwordCtrl.text) {
                                return 'Passwords do not match.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 28),

                          // Create account button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: auth.loading ? null : _submit,
                              child: auth.loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Create Account'),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Divider
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16),
                                child: Text(
                                  'or',
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 13),
                                ),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 20),

                          GoogleSignInButton(
                            onPressed: _googleSignIn,
                            loading: auth.loading,
                          ),
                          const SizedBox(height: 28),

                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account? ',
                                  style: TextStyle(
                                      color: Colors.grey.shade600),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Sign In'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.deepGreen,
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
