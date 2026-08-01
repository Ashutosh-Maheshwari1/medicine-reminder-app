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

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    await ref.read(authNotifierProvider.notifier).signUpWithEmail(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    final state = ref.read(authNotifierProvider);
    if (mounted) {
      state.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                error.toString().contains('email-already-in-use')
                    ? 'An account with this email already exists.'
                    : AppStrings.errorGeneric,
              ),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        },
        data: (user) {
          if (user != null) context.go(Routes.home);
        },
      );
    }
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
              AppColors.success.withOpacity(isDark ? 0.12 : 0.07),
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
                const SizedBox(height: 20),

                // Back button
                IconButton(
                  onPressed: () => context.pop(),
                  icon: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: isDark ? AppColors.darkCard : AppColors.card,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Header
                Text(
                  'Create Account ✨',
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1),

                const SizedBox(height: 8),

                Text(
                  'Start tracking your health journey',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 500.ms).slideX(begin: -0.1),

                const SizedBox(height: 32),

                // Form card
                Container(
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
                        CustomTextField(
                          controller: _nameController,
                          label: AppStrings.fullName,
                          hint: 'Enter your full name',
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.person_outline_rounded),
                          validator: (v) => v == null || v.isEmpty
                              ? AppStrings.errorEmptyField
                              : null,
                        ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _emailController,
                          label: AppStrings.email,
                          hint: 'Enter your email',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.email_outlined),
                          validator: (v) {
                            if (v == null || v.isEmpty) return AppStrings.errorEmptyField;
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                              return AppStrings.errorInvalidEmail;
                            }
                            return null;
                          },
                        ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _passwordController,
                          label: AppStrings.password,
                          hint: 'Create a password',
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return AppStrings.errorEmptyField;
                            if (v.length < 6) return AppStrings.errorWeakPassword;
                            return null;
                          },
                        ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _confirmPasswordController,
                          label: AppStrings.confirmPassword,
                          hint: 'Confirm your password',
                          obscureText: _obscureConfirm,
                          textInputAction: TextInputAction.done,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                          onSubmitted: (_) => _signUp(),
                          validator: (v) {
                            if (v == null || v.isEmpty) return AppStrings.errorEmptyField;
                            if (v != _passwordController.text) {
                              return AppStrings.errorPasswordMismatch;
                            }
                            return null;
                          },
                        ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

                        const SizedBox(height: 28),

                        AnimatedButton(
                          onPressed: isLoading ? null : _signUp,
                          isLoading: isLoading,
                          gradient: AppColors.successGradient,
                          child: Text(
                            AppStrings.signup,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 150.ms, duration: 600.ms).slideY(begin: 0.05),

                const SizedBox(height: 24),

                // Login link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.hasAccount,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text(
                          AppStrings.login,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 700.ms, duration: 400.ms),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
