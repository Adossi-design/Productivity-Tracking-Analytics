import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_auth_provider.dart';
import '../l10n/app_localizations.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
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

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AppAuthProvider>();
    final success = await auth.signUpWithEmail(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    // On success, _AppRoot StreamBuilder auto-navigates to HomeScreen.
    // On failure, show the error.
    if (!success && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(auth.errorMessage ?? 'Sign up failed'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 4),
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final auth = context.watch<AppAuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ────────────────────────────────────────────
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF6366F1),
                                Color(0xFF818CF8)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.person_add_rounded,
                              size: 36, color: Colors.white),
                        ),
                        const SizedBox(height: 20),
                        Text(l.createAccount,
                            style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(l.trackSmarter,
                            style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.white54
                                    : Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Form ──────────────────────────────────────────────
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AuthField(
                          controller: _nameCtrl,
                          hint: l.enterName,
                          label: l.name,
                          icon: Icons.person_outline_rounded,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? l.enterName
                                  : null,
                        ),
                        const SizedBox(height: 16),
                        AuthField(
                          controller: _emailCtrl,
                          hint: l.enterEmail,
                          label: l.email,
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) =>
                              (v == null || !v.contains('@'))
                                  ? l.enterEmail
                                  : null,
                        ),
                        const SizedBox(height: 16),
                        AuthField(
                          controller: _passwordCtrl,
                          hint: l.enterPassword,
                          label: l.password,
                          icon: Icons.lock_outline,
                          obscure: _obscurePass,
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePass
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined),
                            onPressed: () => setState(
                                () => _obscurePass = !_obscurePass),
                          ),
                          validator: (v) =>
                              (v == null || v.length < 6)
                                  ? l.enterPassword
                                  : null,
                        ),
                        const SizedBox(height: 16),
                        AuthField(
                          controller: _confirmCtrl,
                          hint: l.enterConfirmPassword,
                          label: l.confirmPassword,
                          icon: Icons.lock_outline,
                          obscure: _obscureConfirm,
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirm
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined),
                            onPressed: () => setState(
                                () =>
                                    _obscureConfirm = !_obscureConfirm),
                          ),
                          validator: (v) =>
                              v != _passwordCtrl.text
                                  ? l.passwordsDoNotMatch
                                  : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Sign up button ────────────────────────────────────
                  AuthPrimaryButton(
                    label: l.signUp,
                    isLoading: auth.isLoading,
                    onPressed: _signUp,
                  ),
                  const SizedBox(height: 28),

                  // ── Sign in link ──────────────────────────────────────
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l.alreadyHaveAccount,
                            style: TextStyle(
                                color: isDark
                                    ? Colors.white54
                                    : Colors.grey.shade600)),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(l.signIn,
                              style: const TextStyle(
                                  color: Color(0xFF6366F1),
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
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
