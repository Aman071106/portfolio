import 'package:flutter/material.dart';

class AppColors {
  // ── Editorial Dark Palette ──────────────────────────────────────
  // Base
  static const Color backgroundColor = Color(0xFF0A0A0A);
  static const Color surfaceColor = Color(0xFF141414);
  static const Color cardBackground = Color(0xFF1A1A1A);

  // Primary – kept for legacy compat but now used minimally
  static const Color primaryColor = Color(0xFFE8E545); // warm electric yellow
  static const Color primaryDarkColor = Color(0xFFBDB82E);
  static const Color primaryLightColor = Color(0xFFF5F3A0);

  // Text
  static const Color textPrimaryColor = Color(0xFFFFFFFF);
  static const Color textSecondaryColor = Color(0xFF9CA3AF);
  static const Color textLightColor = Color(0xFFFFFFFF);
  static const Color textMutedColor = Color(0xFF6B7280);

  // Accent
  static const Color accentColor = Color(0xFFE8E545);
  static const Color secondaryAccentColor = Color(0xFF4ECDC4);

  // Status
  static const Color mergedColor = Color(0xFF22C55E);
  static const Color openColor = Color(0xFFFBBF24);

  // Image overlay
  static const Color overlayDark = Color(0xCC000000); // 80%
  static const Color overlayMedium = Color(0x99000000); // 60%
  static const Color overlayLight = Color(0x4D000000); // 30%

  // Card / Borders
  static const Color cardColor = Color(0xFF1E1E1E);
  static const Color cardDarkColor = Color(0xFF141414);
  static const Color borderColor = Color(0xFF2A2A2A);

  // Legacy compat aliases
  static const Color darkBackgroundColor = surfaceColor;
  static const Color cardBackgroundColor = cardBackground;
  static const Color aboutSectionBackground = surfaceColor;
  static const Color skillCategoryBackground = cardBackground;
  static const Color skillItemBackground = Color(0xFF1E1E1E);
  static const Color skillItemBorder = borderColor;
  static const Color socialIconBackground = cardBackground;
}
