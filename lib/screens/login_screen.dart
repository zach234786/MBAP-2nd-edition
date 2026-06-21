import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tpmentorship/providers/auth_provider.dart';
import 'package:tpmentorship/services/auth_service.dart';
import 'package:tpmentorship/theme/app_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final VoidCallback onGoToRegister;
  final VoidCallback onGoToForgotPassword;

  const LoginScreen({
    super.key,
    required this.onGoToRegister,
    required this.onGoToForgotPassword,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  void _showSnackBar(String message, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : AppTheme.tpRed,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).login(
            email: _emailController.text,
            password: _passwordController.text,
          );
    } catch (e) {
      _showSnackBar(AuthService.friendlyError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
    } catch (e) {
      _showSnackBar(AuthService.friendlyError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _continueAsGuest() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).signInAnonymously();
    } catch (e) {
      _showSnackBar(AuthService.friendlyError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Stack(
        children: [
          // Bottom gradient (campus background effect)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 200,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.darkBg,
                    AppTheme.tpRed.withValues(alpha: 0.3),
                    AppTheme.tpRed.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              const SizedBox(height: 40),

                              // TP Logo
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppTheme.tpRedLight, AppTheme.tpRed],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.tpRed.withValues(alpha: 0.4),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    const Center(
                                      child: Text(
                                        'TP',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.25),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.people,
                                          color: Colors.white,
                                          size: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Title
                              RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'TP ',
                                      style: TextStyle(
                                        color: AppTheme.tpRed,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Mentorship',
                                      style: TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Connect. Learn. Grow Together',
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                              ),
                              const SizedBox(height: 24),

                              // Register link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Don't have an account? ",
                                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                                  ),
                                  GestureDetector(
                                    onTap: widget.onGoToRegister,
                                    child: const Text(
                                      'Register Here.',
                                      style: TextStyle(
                                        color: AppTheme.tpRed,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Form card
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppTheme.darkCardBg,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppTheme.darkBorder),
                                ),
                                child: Column(
                                  children: [
                                    // Student ID field
                                    TextFormField(
                                      controller: _emailController,
                                      style: const TextStyle(color: AppTheme.textPrimary),
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        hintText: 'Student ID',
                                        hintStyle: const TextStyle(color: AppTheme.textSecondary),
                                        prefixIcon: Container(
                                          margin: const EdgeInsets.all(10),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppTheme.darkBg,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.person_outline,
                                              color: AppTheme.textSecondary, size: 18),
                                        ),
                                        fillColor: AppTheme.darkBg,
                                        filled: true,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: AppTheme.darkBorder),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: AppTheme.darkBorder),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: AppTheme.tpRed, width: 2),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Please enter your Student ID';
                                        }
                                        if (!value.contains('@')) {
                                          return 'Please enter a valid email';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12),

                                    // Password field
                                    TextFormField(
                                      controller: _passwordController,
                                      style: const TextStyle(color: AppTheme.textPrimary),
                                      obscureText: _obscurePassword,
                                      decoration: InputDecoration(
                                        hintText: 'Password',
                                        hintStyle: const TextStyle(color: AppTheme.textSecondary),
                                        prefixIcon: Container(
                                          margin: const EdgeInsets.all(10),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppTheme.darkBg,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.lock_outline,
                                              color: AppTheme.textSecondary, size: 18),
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: AppTheme.textSecondary,
                                            size: 18,
                                          ),
                                          onPressed: () => setState(
                                              () => _obscurePassword = !_obscurePassword),
                                        ),
                                        fillColor: AppTheme.darkBg,
                                        filled: true,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: AppTheme.darkBorder),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: AppTheme.darkBorder),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: AppTheme.tpRed, width: 2),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your password';
                                        }
                                        if (value.length < 6) {
                                          return 'Password must be at least 6 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 4),

                                    // Remember me + Forgot password
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 36,
                                              height: 36,
                                              child: Checkbox(
                                                value: _rememberMe,
                                                onChanged: (value) => setState(
                                                    () => _rememberMe = value ?? false),
                                                fillColor: WidgetStateProperty.resolveWith(
                                                  (states) => states.contains(WidgetState.selected)
                                                      ? AppTheme.tpRed
                                                      : Colors.transparent,
                                                ),
                                                side: const BorderSide(color: AppTheme.tpRed, width: 2),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                              ),
                                            ),
                                            const Text(
                                              'Remember Me?',
                                              style: TextStyle(
                                                  color: AppTheme.textSecondary, fontSize: 13),
                                            ),
                                          ],
                                        ),
                                        GestureDetector(
                                          onTap: widget.onGoToForgotPassword,
                                          child: const Text(
                                            'Forgot Password?',
                                            style: TextStyle(
                                              color: AppTheme.tpRed,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Login button
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.tpRed,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 4,
                                    shadowColor: AppTheme.tpRed.withValues(alpha: 0.5),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Login',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Divider
                              Row(
                                children: const [
                                  Expanded(child: Divider(color: AppTheme.darkBorder)),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                    child: Text('OR',
                                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                  ),
                                  Expanded(child: Divider(color: AppTheme.darkBorder)),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Google sign-in
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: OutlinedButton.icon(
                                  onPressed: _isLoading ? null : _signInWithGoogle,
                                  icon: const Icon(Icons.g_mobiledata,
                                      color: AppTheme.tpRed, size: 28),
                                  label: const Text('Continue with Google'),
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Anonymous sign-in
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: OutlinedButton.icon(
                                  onPressed: _isLoading ? null : _continueAsGuest,
                                  icon: const Icon(Icons.person_outline, color: AppTheme.tpRed),
                                  label: const Text('Continue as Guest'),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
