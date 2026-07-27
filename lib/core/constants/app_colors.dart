import 'package:flutter/material.dart';

/// Central color palette for MediTrack AI
class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF2F80ED);
  static const Color primaryLight = Color(0xFF56CCF2);
  static const Color primaryDark = Color(0xFF1A5BB8);

  // Accent
  static const Color accent = Color(0xFF56CCF2);

  // Status Colors
  static const Color success = Color(0xFF27AE60);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFF2C94C);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color danger = Color(0xFFEB5757);
  static const Color dangerLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF2F80ED);
  static const Color infoLight = Color(0xFFE3F2FD);

  // Light Theme
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE8ECF0);
  static const Color divider = Color(0xFFEEF1F5);
  static const Color textPrimary = Color(0xFF1A1D23);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFB0B7C3);
  static const Color inputFill = Color(0xFFF3F6FB);
  static const Color inputBorder = Color(0xFFDDE3EC);

  // Dark Theme (AMOLED)
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF0D0D0D);
  static const Color darkCard = Color(0xFF1A1A1A);
  static const Color darkCardBorder = Color(0xFF2A2A2A);
  static const Color darkDivider = Color(0xFF1F1F1F);
  static const Color darkTextPrimary = Color(0xFFF5F7FA);
  static const Color darkTextSecondary = Color(0xFF9EA5B1);
  static const Color darkTextHint = Color(0xFF5A606B);
  static const Color darkInputFill = Color(0xFF1A1A1A);
  static const Color darkInputBorder = Color(0xFF2D2D2D);

  // Medicine Type Colors
  static const Color tabletColor = Color(0xFF2F80ED);
  static const Color capsuleColor = Color(0xFFEB5757);
  static const Color injectionColor = Color(0xFFF2C94C);
  static const Color dropsColor = Color(0xFF27AE60);
  static const Color syrupColor = Color(0xFF9B51E0);
  static const Color otherColor = Color(0xFF6B7280);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2F80ED), Color(0xFF56CCF2)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A5BB8), Color(0xFF2F80ED), Color(0xFF56CCF2)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF27AE60), Color(0xFF6FCF97)],
  );

  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF2C94C), Color(0xFFF2994A)],
  );

  static const LinearGradient dangerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEB5757), Color(0xFFFF8A8A)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E1E1E), Color(0xFF141414)],
  );
}
