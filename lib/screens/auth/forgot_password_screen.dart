import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/animated_button.dart';
import '../../widgets/common/custom_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSent = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await ref
          .read(authNotifierProvider.notifier)
          .sendPasswordReset(_emailController.text);
      if (mounted) setState(() => _isSent = true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to send reset email. Please try again.'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _isSent ? _buildSuccessView(isDark) : _buildFormView(isDark),
        ),
      ),
    );
  }

  Widget _buildFormView(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.15),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Center(child: Text('🔐', style: TextStyle(fontSize: 32))),
        ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8)),

        const SizedBox(height: 24),

        Text(
          'Reset Password',
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ).animate().fadeIn(delay: 100.ms, duration: 500.ms),

        const SizedBox(height: 8),

        Text(
          "Enter your email and we'll send you a link to reset your password.",
          style: GoogleFonts.outfit(
            fontSize: 15,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            height: 1.5,
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

        const SizedBox(height: 36),

        Form(
          key: _formKey,
          child: CustomTextField(
            controller: _emailController,
            label: 'Email address',
            hint: 'Enter your email',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter your email.';
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                return 'Please enter a valid email.';
              }
              return null;
            },
          ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
        ),

        const SizedBox(height: 28),

        AnimatedButton(
          onPressed: _isLoading ? null : _sendReset,
          isLoading: _isLoading,
          gradient: AppColors.warningGradient,
          child: Text(
            'Send Reset Link',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
      ],
    );
  }

  Widget _buildSuccessView(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('✉️', style: TextStyle(fontSize: 48)),
            ),
          ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.6, 0.6)),

          const SizedBox(height: 28),

          Text(
            'Check your inbox!',
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

          const SizedBox(height: 12),

          Text(
            'We\'ve sent a password reset link to\n${_emailController.text}',
            style: GoogleFonts.outfit(
              fontSize: 15,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms, duration: 500.ms),

          const SizedBox(height: 36),

          AnimatedButton(
            onPressed: () => Navigator.pop(context),
            gradient: AppColors.primaryGradient,
            child: const Text('Back to Login',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
          ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
        ],
      ),
    );
  }
}
