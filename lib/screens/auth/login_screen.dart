import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_router.dart';
import '../../widgets/common/animated_button.dart';
import '../../widgets/common/custom_text_field.dart';

/// Premium login screen with glass card and animations
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    await ref.read(authNotifierProvider.notifier).signInWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
        );

    final state = ref.read(authNotifierProvider);
    if (mounted) {
      state.whenOrNull(
        error: (error, _) => _showError(error.toString()),
        data: (user) {
          if (user != null) context.go(Routes.home);
        },
      );
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => _isGoogleLoading = true);
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();

    final state = ref.read(authNotifierProvider);
    if (mounted) {
      setState(() => _isGoogleLoading = false);
      state.whenOrNull(
        error: (error, _) => _showError(error.toString()),
        data: (user) {
          if (user != null) context.go(Routes.home);
        },
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message.contains('wrong-password') || message.contains('invalid-credential')
              ? 'Invalid email or password. Please try again.'
              : message.contains('user-not-found')
                  ? 'No account found with this email.'
                  : 'Something went wrong. Please try again.',
        ),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [
              AppColors.primary.withOpacity(isDark ? 0.15 : 0.08),
              isDark ? AppColors.darkBackground : AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),

                // Header
                _buildHeader(isDark),

                const SizedBox(height: 40),

                // Login form card
                _buildFormCard(context, isDark, isLoading),

                const SizedBox(height: 24),

                // Sign up link
                _buildSignupLink(isDark),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Text('💊', style: TextStyle(fontSize: 32)),
          ),
        ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.8, 0.8)),

        const SizedBox(height: 28),

        Text(
          'Welcome back! 👋',
          style: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideX(begin: -0.1),

        const SizedBox(height: 8),

        Text(
          'Sign in to manage your medicines',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideX(begin: -0.1),
      ],
    );
  }

  Widget _buildFormCard(BuildContext context, bool isDark, bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Email field
            CustomTextField(
              controller: _emailController,
              label: AppStrings.email,
              hint: 'Enter your email',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              prefixIcon: const Icon(Icons.email_outlined),
              validator: (value) {
                if (value == null || value.isEmpty) return AppStrings.errorEmptyField;
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return AppStrings.errorInvalidEmail;
                }
                return null;
              },
            ).animate().fadeIn(delay: 400.ms, duration: 500.ms).slideY(begin: 0.1),

            const SizedBox(height: 16),

            // Password field
            CustomTextField(
              controller: _passwordController,
              label: AppStrings.password,
              hint: 'Enter your password',
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
              onSubmitted: (_) => _signIn(),
              validator: (value) {
                if (value == null || value.isEmpty) return AppStrings.errorEmptyField;
                if (value.length < 6) return AppStrings.errorWeakPassword;
                return null;
              },
            ).animate().fadeIn(delay: 500.ms, duration: 500.ms).slideY(begin: 0.1),

            const SizedBox(height: 12),

            // Remember me + Forgot password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Transform.scale(
                      scale: 0.9,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (v) => setState(() => _rememberMe = v ?? false),
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Text(
                      'Remember me',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => context.push(Routes.forgotPassword),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  ),
                  child: Text(
                    AppStrings.forgotPassword,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 550.ms, duration: 500.ms),

            const SizedBox(height: 24),

            // Login button
            AnimatedButton(
              onPressed: isLoading ? null : _signIn,
              isLoading: isLoading,
              gradient: AppColors.primaryGradient,
              child: Text(
                AppStrings.login,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ).animate().fadeIn(delay: 600.ms, duration: 500.ms).slideY(begin: 0.1),

            const SizedBox(height: 20),

            // Divider
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: isDark ? AppColors.darkDivider : AppColors.divider,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    AppStrings.orContinueWith,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: isDark ? AppColors.darkDivider : AppColors.divider,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 650.ms, duration: 500.ms),

            const SizedBox(height: 20),

            // Google Sign In button
            _GoogleSignInButton(
              isLoading: _isGoogleLoading,
              onPressed: _googleSignIn,
              isDark: isDark,
            ).animate().fadeIn(delay: 700.ms, duration: 500.ms),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 350.ms, duration: 600.ms).slideY(begin: 0.05);
  }

  Widget _buildSignupLink(bool isDark) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppStrings.noAccount,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => context.push(Routes.signup),
            child: Text(
              AppStrings.signup,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms, duration: 500.ms);
  }
}

class _GoogleSignInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final bool isDark;

  const _GoogleSignInButton({
    required this.isLoading,
    required this.onPressed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppColors.darkInputFill : AppColors.inputFill,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkInputBorder : AppColors.inputBorder,
              width: 1.5,
            ),
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Google logo
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: const Text('G',
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                color: Color(0xFF4285F4))),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        AppStrings.signInWithGoogle,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
